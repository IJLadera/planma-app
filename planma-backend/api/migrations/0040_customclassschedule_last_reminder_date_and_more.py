# Generated by Django 5.1.8 on 2025-04-28 18:47

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0039_alter_customactivity_activity_desc_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='customclassschedule',
            name='last_reminder_date',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='goals',
            name='last_reminder_date',
            field=models.DateField(blank=True, null=True),
        ),
    ]
