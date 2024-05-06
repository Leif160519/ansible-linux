## jumpserver获取private token
```
docker exec -it jms_core /bin/bash
cd /opt/jumpserver/apps
python manage.py shell
from users.models import User
u = User.objects.get(username='admin')
u.create_private_token()
```

已经存在 private_token，可以直接获取即可
```
u.private_token
```

以 PrivateToken: 937b38011acf499eb474e2fecb424ab3 为例:
```
curl http://demo.jumpserver.org/api/v1/users/users/ \
     -H 'Authorization: Token 937b38011acf499eb474e2fecb424ab3' \
     -H 'Content-Type: application/json' \
     -H 'X-JMS-ORG: 00000000-0000-0000-0000-000000000002'
```

## 参考
- [API 认证][1]

[1]: https://docs.jumpserver.org/zh/master/dev/rest_api/
