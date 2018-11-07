from django.db import models

from userprofile.models import User

# Create your models here.
class Space(models.Model):
    name = models.CharField(max_length=250, blank=True)
    user_space = models.ForeignKey(User, related_name='+', blank=False, null=True, on_delete=models.CASCADE)

