# Generated by Django 2.1.3 on 2018-11-02 22:07

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('space', '0001_initial'),
    ]

    operations = [
        migrations.RenameModel(
            old_name='User',
            new_name='Space',
        ),
    ]
