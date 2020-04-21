from .base import *

import os


INSTALLED_APPS += ('django_nose',)

# TEST_RUNNER = 'django_nose.NoseTestSuiteRunner'
TEST_OUPTPUT_DIR = os.environ.get('TEST_OUPTPUT_DIR', ".")

NOSE_ARGS = [

    '--verbosity=2',
    '--nologcapture',
    '--with-coverage',
    '--with-spec',
    '--spec-color',
    '--with-xunit',
    '--xunit-file=%s/unittests.xml' % TEST_OUPTPUT_DIR,
    '--cover-xml',
    '--cover-xml-file=%s/coverage.xml' % TEST_OUPTPUT_DIR

]

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
