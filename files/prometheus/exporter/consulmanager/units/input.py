#!/usr/bin/python3
import requests,json
consul_token = '9ce1358e-da13-4b7b-b79e-7f7b16408d47'
consul_url = 'http://10.1.1.24:8500/v1'

with open('instance.list', 'r') as file:
  lines = file.readlines()
  for line in lines:
    module,company,project,env,name,instance = line.split()
    headers = {'X-Consul-Token': consul_token}
    data = {
            "id": f"{module}/{company}/{project}/{env}@{name}",
            "name": 'blackbox_exporter',
            "tags": [module],
            "Meta": {'module':module,'company':company,'project':project,'env':env,'name':name,'instance':instance}
           }

    reg = requests.put(f"{consul_url}/agent/service/register", headers=headers, data=json.dumps(data))
    if reg.status_code == 200:
        print({"code": 20000,"data": "增加成功！"})
    else:
        print({"code": 50000,"data": f'{reg.status_code}:{reg.text}'})
