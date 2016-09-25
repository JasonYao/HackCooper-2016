from django.conf.urls import include, url
from . import views


urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^', include('registration.backends.default.urls'), name='Registration'),
]

#url(r'^dashboard/$', views.lobby, name='Lobby'),
# TODO Require unique email (nonworking yet)
# url(r'^register/$', 'registration.views.register' {'form_class':RegistrationFormUniqueEmail, 'backend':'registration.backends.default.DefaultBackend' }),
