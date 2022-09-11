from shutil import ExecError
from time import sleep
import boto3 as bt
import os, os.path 
import paramiko
from pprint import pprint

def separators(count_of_separators : int):
    def _wrapper2(func):
        def _wrapper(*args, **kwargs):
            print("*"*count_of_separators)
            print(f"Starting step {func.__name__}")
            func(*args, **kwargs)
            print(f"Finished with {func.__name__}")
        return _wrapper
    return _wrapper2

class Manager(object):
    session: bt.Session
    ec2_client: object
    ec2: object
    params: dict 
    instance: object
    instance_volume: object
    instance_image: object
    key_pair_path: str

    
    def __init__(self, **params):
        try:
            self.params = dict(params)
            
            # Searching in local directory credentials file and adding it to environ
            credentials = None
            for parent_dir, _, files in os.walk(os.getcwd()):
                if params['credentials_filename'] in files:
                    credentials =  os.path.join(parent_dir, 'credentials')
                    break
            if (credentials is None):
                raise Exception("[ERROR] - Credentials not found")
            os.environ['AWS_SHARED_CREDENTIALS_FILE'] = credentials
            print(os.environ['AWS_SHARED_CREDENTIALS_FILE'])
            
            # Searching of the SSH-key by name in local directory
            key = None
            for parent, _, files in os.walk(os.getcwd()):
                if(params['key_pair_name'] in files):
                    key = os.path.join(parent, params['key_pair_name'])
                    print(key)
                    break
            self.key_pair_path = key
            if(self.key_pair_path is None):
                raise Exception('[ERROR] - SSH-key not found!')
            # Creating session for user and getting EC2 client 
            self.session = bt.Session(profile_name=params['profile_name'],
                                      region_name=params['region_name'])
            self.ec2_client = self.session.client('ec2')
            # Creating EC2 resource for low-level requests 
            self.ec2 = bt.resource('ec2', region_name='us-east-1')       

        except Exception as e:
            print("Exception!", e)
            exit(1)

    @separators(100)
    def create_ec2_instance(self):
        try:
            pprint(f'Creating EC2 instance with params : {self.params}')

            # Creating instance with requested params
            instanceId = self.ec2_client.run_instances(
                KeyName='another-key',
                ImageId=self.params['ImageId'],
                InstanceType=self.params['InstanceType'],
                SubnetId=self.params['SubnetId'],
                MinCount=self.params['MinCount'],
                MaxCount=self.params['MaxCount']
            )['Instances'][0]['InstanceId']
            print('Request for creation sent')
            sleep(1)

            # Assigning instance's values
            self.instance = self.ec2.Instance(instanceId)
            self.instance_volume = self.ec2.Volume(self.instance.block_device_mappings[0]['Ebs']['VolumeId'])
            self.instance_image = self.ec2.Image(self.instance.image_id)

            # Waiting
            print("pending instance...")
            self.instance.wait_until_running()
            print("\nInstance is created!")
            
            self.show_instance_info()
            
        except Exception as e:
            print(e) 
            self.terminate_ec2_instance()
            exit(1)


    @separators(100)
    def change_ec2_instance_keypair(self):
        print("Starting SSH-key changing...\nStopping instance...")

        # Creating temporary instance 
        print("Creating temporary instance...")
        temp_instance = self.ec2.Instance(
            self.ec2_client.run_instances(
                KeyName='sisoi-key-pair',
                ImageId=params['ImageId'],
                InstanceType=params['InstanceType'],
                SubnetId=params['SubnetId'],
                MinCount=params['MinCount'],
                MaxCount=params['MaxCount']
            )['Instances'][0]['InstanceId']
        )

        # Stoppig instance for volume detaching
        self.instance.stop()
        self.instance.wait_until_stopped()
        print("Instance is stopped!\nDetaching volume...")

        # Detaching volume from instance
        response = self.instance_volume.detach_from_instance(InstanceId=self.instance.instance_id)
        print("Pending temporary instance...")
        temp_instance.wait_until_running()
        print("Temporary instance created!\nAttaching volume...")
        temp_instance.attach_volume(Device=response['Device'][:-1]+"2",
                                    VolumeId=self.instance_volume.volume_id)
        print("Volume attached!\nStarting SSH-changing....")

        # Waiting until temp instance initialize
        self.wait_until_initialized(temp_instance)

        # Changing SSH-key on initial instance
        try:

            # Commands that will be executed on temp instance
            commands = [r'sudo mkdir -pv /mnt/temp', 
                        r'sudo mount -v /dev/xvdb1 /mnt/temp;',
                        r'sleep 3',
                        r'sudo mkdir -pv /mnt/temp/home/ubuntu/.ssh/',
                        r'sudo cp -fvT /home/ubuntu/.ssh/authorized_keys  /mnt/temp/home/ubuntu/.ssh/authorized_keys',
                        r'sudo umount -lv /mnt/temp']

            # Executing remote commands on ec2 temp instance
            self.ssh_exec(host=temp_instance.public_ip_address, key_pair_path=self.key_pair_path,
                     user='ubuntu', port=22, commands=commands)
        except Exception as e:
            print(e)
            temp_instance.terminate()
            self.terminate_ec2_instance()
            exit(1)

        # Detaching volume and attaching it back to the instance 
        print('Succeed with SSH-key changing!\nDetaching volume from temp instance...')
        temp_instance.detach_volume(VolumeId=self.instance_volume.volume_id)
        try:
            while self.instance_volume.attachments[0]['State'] != 'detached':
                self.instance_volume.load()
                sleep(5)
        except IndexError as e:
            print("Attaching volume back to instance...")

        # Terminating temp instance
        temp_instance.terminate()

        # Attaching volume back to instance
        self.instance.attach_volume(Device=response['Device'],
                                    VolumeId=self.instance_volume.volume_id)
        print("Starting instance....")

        # Starting instance and wait until it's running
        self.instance.start()
        self.instance.wait_until_running()

        # Testing results of SSH-key changing
        print("Testing operation!")

        # Wait instance initialized
        self.wait_until_initialized(self.instance)
        try:
            # Commands to be executed
            commands = [r'sudo uname -a',
                        r'sudo ip l']

            # Execute remote commands
            self.ssh_exec(host=self.instance.public_ip_address, key_pair_path=self.key_pair_path,
                          user='ubuntu', port=22, commands=commands)
        except Exception as e:
            print(e)
            self.terminate_ec2_instance()
            exit(1)
            
        print("Operation succeed!")
        temp_instance.wait_until_terminated()      
        print("Deleted temp instances!")


    @separators(100)
    def awscli_installation(self):
        try:
            print('Installing awscli on the instance!')
            os_name = self.instance_image.name

            # Installation for ubuntu
            if (os_name.split('/')[0] == 'ubuntu'):
                self.ssh_exec(host=self.instance.public_ip_address, key_pair_path=self.key_pair_path,
                              user='ubuntu', port=22, commands=[r'sudo apt-get update -y',
                                                                r'sudo apt install -y awscli',
                                                                r'sudo aws --version'])

            # Installation for Red Hat's distro
            elif (os_name.split('-')[0] == 'RHEL'):
                self.ssh_exec(host=self.instance.public_ip_address, key_pair_path=self.key_pair_path,
                              user='ec2-user', port=22, commands=[r'sudo yum update -y',
                                                                  r'sudo yum install awscli -y',
                                                                  r'sudo aws --version'])

            # Installation for Debian
            elif (os_name.split('-')[0] == 'debian'):
                self.ssh_exec(host=self.instance.public_ip_address, key_pair_path=self.key_pair_path,
                              user='admin', port=22, commands=[r'sudo apt-get update -y',
                                                                r'sudo apt install -y awscli',
                                                                r'sudo aws --version'])
        except Exception as e:
            print(e)
            self.terminate_ec2_instance()
            exit(1)
            

    @separators(100)
    def terminate_ec2_instance(self):      
        print("Terminating the instance...")
        self.instance.terminate()
        self.instance.wait_until_terminated()
        print('Instance is terminated!')


    def ssh_exec(self, *, host, key_pair_path, user, port, commands):
        # Creating rsa-object from public key
        key = paramiko.RSAKey.from_private_key_file(key_pair_path)

        # Creating SSH-client 
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        print(ssh_client.get_host_keys().keys(), ssh_client.get_host_keys().items())

        # Connecting to remote host
        ssh_client.connect(hostname=host, port=port, username=user, pkey=key)

        # Executing commands one-by-one and printing results to stdout
        for cmd in commands:
            _, stdout, stderr = ssh_client.exec_command(cmd)
            print(f'cmd : {cmd}')
            print('  output:\n', ('  '*2) + ('\n' + '  '*2).join(stdout.read().decode('utf-8').split('\n')))
            print('\n  errors:\n', ('  '*2) + ('\n' + '  '*2).join(stderr.read().decode('utf-8').split('\n')))
        ssh_client.close()


    def show_instance_info(self):
        print("\nInstance description:", "\nimage id: ", self.instance.image_id, 
                          "\ninstance id: ", self.instance.instance_id, 
                          "\ncpu options: ", self.instance.cpu_options,
                          "\narchitecture: ", self.instance.architecture,
                          "\nplatform: ", self.instance.platform_details,
                                    self.instance_image.name,
                          "\nblock device mappings: ", self.instance.block_device_mappings,
                          "\nblock storage desc: ", "size -", self.instance_volume.size,"; iops - ", self.instance_volume.iops,
                                    "; state -", self.instance_volume.state, "; troughput -", 
                                    self.instance_volume.throughput, "; type -", self.instance_volume.volume_type,   
                          "\nkey name: ", self.instance.key_name,
                          "\npublic ip: ", self.instance.public_ip_address,
                          "\nprivate ip: ", self.instance.private_ip_address,
                          "\nmonitoring: ", self.instance.monitoring)


    def change_params(self, **params):
        self.params = dict(params)
        # Searching in local directory credentials file and adding it to environ
        for parent_dir, _, files in os.walk(os.getcwd()):
            if params['credentials_filename'] in files:
                credentials =  os.path.join(parent_dir, 'credentials')
                print(credentials)
                break
        os.environ['AWS_SHARED_CREDENTIALS_FILE'] = credentials
        print(os.environ['AWS_SHARED_CREDENTIALS_FILE'])
        # Searching of the SSH-key by name in local directory
        for parent, _, files in os.walk(os.getcwd()):
            if(params['key_pair_name'] in files):
                self.key_pair_path = os.path.join(parent, params['key_pair_name'])
                print(self.key_pair_path)
                break
        # Creating session for user and getting EC2 client 
        self.session = bt.Session(profile_name=params['profile_name'],
                                  region_name=params['region_name'])
        self.ec2_client = self.session.client('ec2')
        # Creating EC2 resource for low-level requests 
        self.ec2 = bt.resource('ec2', region_name='us-east-1')

    
    def wait_until_initialized(self, *instances):
        instance_id_list = [i.instance_id for i in instances]
        while self.ec2_client.describe_instance_status(InstanceIds=instance_id_list)['InstanceStatuses'][0]['SystemStatus']['Status'] != 'ok':
            print(f'waiting instances {instance_id_list} initialize..')
            sleep(20)




if __name__ == '__main__': 
    params = dict(
        # instance launch settings
        ImageId="ami-052efd3df9dad4825",
        InstanceType='t2.micro',
        SubnetId='subnet-0a310f8386879feda',
        MinCount=1,
        MaxCount=1,
        # resource settings
        region_name='us-east-1',
        profile_name='dev',
        # name of the credentials and SSH-key
        credentials_filename='credentials',
        key_pair_name = "sisoi-key-pair.pem"
    )
    print("ENTRYPOINT")
    mg = Manager(**params)
    mg.create_ec2_instance()
    # input('Press enter to CHANGE SSH-KEY..')
    mg.change_ec2_instance_keypair()
    mg.awscli_installation()
    mg.show_instance_info()
    # input('Press enter to TERMINATE instance..') 
    mg.terminate_ec2_instance()
    print("ENDPOINT")
    
    