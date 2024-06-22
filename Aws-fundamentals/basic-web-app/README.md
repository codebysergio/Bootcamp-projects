This is a basic web application with a sucure, robust, and scalable backend.

The ec2 instance has a public ip associated allowing public traffic to hit it.
The ec2 instance is also in a public subnet, with a security group protecting it
The RDS insance on the other hand is not publicly available with a security group protecting it, while sitting in a private subnet.
To keep thing organized and in the same network everything was provisioned in the same vpc.

components:
> ec2 instance (hosts web app)
> rds instance (holds web app data)
> vpc (groups resources)
> public subnet (group of ip's)
> private subnet (group of ip's)

Traceroute - user>ec2>db>ec2>user