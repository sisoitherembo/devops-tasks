import boto3
import os

if __name__ == '__main__':
    l = ['ami-052efd3df9dad4825', 'ami-0cff7528ff583bf9a', 'ami-05912b6333beaa478', 'ami-06640050dc3f556bb', 'ami-09a41e26df464c548']
    os.environ['AWS_SHARED_CREDENTIALS_FILE'] = r'D:\PYTHON\DevOps PlaysDev\tasks\python\task10\credentials'
    client = boto3.Session(profile_name='dev', region_name='us-east-1').client('ec2')
    res = boto3.resource('ec2', region_name='us-east-1')
    for i in l:
        print(res.Image(i).name)