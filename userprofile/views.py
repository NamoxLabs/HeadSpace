from django.http import HttpResponse
from django.template import loader

from django.shortcuts import render

from .models import User

def index(request):
    latest_users_list = User.objects.order_by('date_joined')[:5]
    #template = loader.get_template('users/index.html')
    context = {
        'latest_users_list': latest_users_list,
    }
    return render(request, 'users/index.html', context)