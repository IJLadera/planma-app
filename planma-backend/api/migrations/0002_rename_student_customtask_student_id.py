# Generated by Django 5.1.3 on 2024-11-15 16:04

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='customtask',
            old_name='student',
            new_name='student_id',
        ),
    ]
