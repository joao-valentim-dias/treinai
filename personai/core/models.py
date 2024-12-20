from django.db import models
from django.contrib.auth.models import User

class UserProfile(models.Model):
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    idade = models.IntegerField()
    peso = models.IntegerField()
    massa_magra = models.IntegerField(blank=True, null=True) # Informção opcional para o usuário regularmente
    metas = models.TextField()
    frequencia = models.TextField()
    descanso = models.JSONField(default=dict)
    

    def __str__(self):
        return f"Perfil de {self.usuario.username}"

class FichaDeTreino(models.Model):
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name="ficha_de_treino")
    exercicios = models.TextField()