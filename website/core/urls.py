from django.conf.urls import include, url
from . import views


urlpatterns = [
    url(r'^$', views.index, name='Home'),
    url(r'^dashboard/$', views.dashboard, name='Dashboard'),
    url(r'^', include('registration.backends.default.urls'), name='Registration'),
]

# TODO Require unique email (nonworking yet)
# url(r'^register/$', 'registration.views.register' {'form_class':RegistrationFormUniqueEmail, 'backend':'registration.backends.default.DefaultBackend' }),
