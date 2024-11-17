# Usage: locust -f locustfile.py --headless --users 2 --spawn-rate 1 -H http://user-management-service:8000
import logging

from locust import HttpUser, task

api_users = "/api/v1/users"

class BaseUser(HttpUser):
    host = "http://0.0.0.0:8000"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.name = None
        self.id = None

    def on_start(self):
        if self.id is None:
            with self.client.post(f"{api_users}/", json={"name": 'name'}) as response:
                data = response.json()
                self.id = data['id']
                self.name = data['name']

    def on_stop(self):
        self.client.delete(f"{api_users}/{self.id}/")

    @task(6)
    def users(self):
        self.client.get(f"{api_users}/")

    @task(2)
    def get(self):
        self.client.get(f"{api_users}/{self.id}/")

    @task(4)
    def update(self):
        self.client.patch(f"{api_users}/{self.id}/", params={"name": 'name'})

    @task(8)
    def error(self):
        self.client.get("/error/")

if __name__ == "__main__":
    from locust.env import Environment
    my_env = Environment(user_classes=[BaseUser])
    BaseUser(my_env).run()