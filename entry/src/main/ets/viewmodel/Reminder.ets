import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Observed
export default class Reminder {
  private _reminderOpen = AppStorage.link<boolean>('reminderOpen');

  get reminderOpen() {
    return this._reminderOpen.get();
  }

  set reminderOpen(val: boolean) {
    if (val) {
      this.setReminder();
    } else {
      this.removeReminder();
    }

    this._reminderOpen.set(val);
  }


  private async setReminder() {
    const oneMinutesLater = new Date(Date.now() + 60 * 1000);
    console.info(oneMinutesLater.toString());

    let targetReminderAgent: reminderAgentManager.ReminderRequestAlarm = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM, // The reminder type is alarm.
      hour: oneMinutesLater.getHours(), // Hour portion of the reminder time.
      minute: oneMinutesLater.getMinutes(), // Minute portion of the reminder time.
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Days of a week when the reminder repeats.
      actionButton: [// Set the button type and title displayed for the reminder in the notification panel.
        {
          title: 'close',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
        }
      ],
      wantAgent: {
        // Information about the target UIAbility that is displayed after the reminder notification is touched.
        pkgName: 'com.sample.timednotification',
        abilityName: 'EntryAbility'
      },
      ringDuration: 5, // Ringing duration, in seconds.
      // snoozeTimes: 2, // Number of reminder snooze times.
      // timeInterval: 5 * 60, // Reminder snooze interval, in seconds.
      title: 'Keep Calm', // Reminder title.
      content: 'Do not forget to smile :)', // Reminder content.
      // expiredContent: 'this reminder has expired', // Content to be displayed after the reminder expires.
      // snoozeContent: 'remind later', // Content to be displayed when the reminder is snoozed.
      notificationId: 1, // Notification ID used by the reminder.
      // If there are reminders with the same notification ID, the later one will overwrite the earlier one.
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION // Type of the slot used by the reminder.
    };

    await reminderAgentManager.publishReminder(targetReminderAgent).then((res: number) => {
      let reminderId: number = res; // ID of the published reminder.
      AppStorage.set('reminderId', reminderId);
      console.info('Succeeded in publishing reminder.', reminderId);
    }).catch((err: BusinessError) => {
      console.error(`Failed to publish reminder. Code: ${err.code}, message: ${err.message}`);
    });
  }

  private async removeReminder() {
    let reminderId: number = AppStorage.get('reminderId') as number;
    // The reminder ID is obtained from the callback after the reminder is published.
    await reminderAgentManager.cancelReminder(reminderId).then(() => {
      console.info('Succeeded in canceling reminder.', reminderId);
    }).catch((err: BusinessError) => {
      console.error(`Failed to cancel reminder. Code: ${err.code}, message: ${err.message}`);
    });
  }
}