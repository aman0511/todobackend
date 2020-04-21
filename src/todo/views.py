from django.urls import reverse

from rest_framework import viewsets, response

from todo.serializers import TodoItemSerializer
from todo.models import TodoItem

# Create your views here.


class TodoItemViewSet(viewsets.ModelViewSet):
    queryset = TodoItem.objects.all()
    serializer_class = TodoItemSerializer

    def perform_create(self, serializer):
        instance = serializer.save()
        instance.url = reverse('todoitem-detail', args=[instance.pk])

    def delete(self, request):
        TodoItem.objects.all().delete()
        return response.Response("ok")
