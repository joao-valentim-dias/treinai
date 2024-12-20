# Generated by Django 5.1.1 on 2024-12-19 20:31

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('chatbot', '0001_initial'),
        ('core', '0002_fichadetreino'),
    ]

    operations = [
        migrations.AlterField(
            model_name='chatbot',
            name='user',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='GeminiUser', to='core.userprofile'),
        ),
        migrations.AlterField(
            model_name='treinos',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='Treinos', to='core.userprofile'),
        ),
    ]