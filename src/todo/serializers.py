from rest_framework import serializers

from todo.models import TodoItem


class TodoItemSerializer(serializers.ModelSerializer):

    class Meta:
        model = TodoItem
        fields = "__all__"
        read_only_fields = ('url',)
