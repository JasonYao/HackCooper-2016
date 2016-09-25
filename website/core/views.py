from django.shortcuts import get_object_or_404, render
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate, login

from .models import Profile


##
# Global views that are not a part of any one particular app goes here
##

def index(request):
    """
    Renders the homepage view
    """
    return render(request, 'core/index.html', {})

