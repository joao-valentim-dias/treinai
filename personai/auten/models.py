from django.contrib.auth.models import AbstractUser, User
from django.db import models

from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    is_staff = models.BooleanField(default=False)  # Não será staff por padrão
    is_superuser = models.BooleanField(default=False)  # Sem privilégios administrativos


class UserProfile(models.Model):
    usuario = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name="profile")
    idade = models.IntegerField()
    peso = models.IntegerField()
    massa_magra = models.IntegerField(blank=True, null=True) # Informção opcional para o usuário regularmente
    metas = models.TextField()
    

    def __str__(self):
        return f"Perfil de {self.usuario.username}"

