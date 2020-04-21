import  os

from .base import  *

if os.environ.get('DEBUG'):
    DEBUG = True
else:
    DEBUG = False


ALLOWED_HOSTS = [os.environ.get('ALLOWED_HOSTS', "*")]


DATABASES = {
    'default': {
        'ENGINE': "django.db.backends.mysql",
        "NMAE": os.environ.get('MYSQL_DATABASE', 'todobackend'),
        "USER": os.environ.get('MYSQL_USER', "todo"),
        "PASSWORD": os.environ.get("MYSQL_PASSWORD", "password"),
        "HOST": os.environ.get("MYSQL_HOST", "localhost"),
        "PORT": os.environ.get("MYSQL_PORT", "3306")
    }
}


STATIC_ROOT = os.path.join(BASE_DIR, "/var/www/todobackend/static")
MEDIA_ROOT = os.path.join(BASE_DIR, "/var/www/todobackend/media")
