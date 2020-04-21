from django.urls import reverse

from rest_framework import status
from rest_framework.test import APITestCase
# Create your tests here.


def createItem(client):
    url = reverse('todoitem-list')

    data = {'title': 'wlak the dog'}

    return client.post(url, data, format='json')


class TestCreateTodoItem(APITestCase):
    """
    """

    def setUp(self):
        self.response = createItem(self.client)

    def test_received_201_created_status_code(self):
        self.assertEqual(self.response.status_code, status.HTTP_201_CREATED)
