

from rest_framework.routers import DefaultRouter

from todo import views

router = DefaultRouter()


router.register("todos", views.TodoItemViewSet)

urlpatterns = [

] + router.urls
