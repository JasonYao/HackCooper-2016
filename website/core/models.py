from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save

# Models here

##
# Global models that are not a part of any one particular app goes here
##

class TimeStampedModel(models.Model):
    """
    An abstract base class model that provides self-
    updating `created` and `modified` fields.
    """
    # Data modification meta data
    created = models.DateTimeField(auto_now_add=True, verbose_name='Created')
    modified = models.DateTimeField(auto_now=True, verbose_name='Modified')

    class Meta:
        abstract = True


class Profile(models.Model):
    """
    An extended version of Django's authenticated user
    that contains our custom requirements
    """
    # Attached user for auth purposes
    user = models.OneToOneField(User, on_delete=models.CASCADE, verbose_name='User')

    # Profile picture
    avatar = models.ImageField(blank=True, verbose_name='Avatar')

    # Note: No need to add the creation/update meta data, since django's auth user handles that for us already

    # Note: No need to add user_id as django adds that automatically- see https://docs.djangoproject.com/en/1.9/topics/db/models/#automatic-primary-key-fields
    def __str__(self):
        return self.user.username


def create_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

post_save.connect(create_profile, sender=User)
