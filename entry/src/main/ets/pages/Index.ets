import Reminder from '../viewmodel/Reminder'
import { notificationManager } from '@kit.NotificationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct Index {
  @State reminder: Reminder = new Reminder()

  aboutToAppear(): void {
    this.getPermission(this.getUIContext().getHostContext() as common.UIAbilityContext)
  }

  build() {
    RelativeContainer() {
      Column() {
        Row() {
          SymbolGlyph($r(this.reminder.reminderOpen ? 'sys.symbol.bell_fill' : 'sys.symbol.bell_slash_fill'))
            .fontColor([Color.White])

          Text('Reminder')
            .padding({ left: 4 })

          Blank().layoutWeight(1)

          Toggle({
            type: ToggleType.Switch,
            isOn: this.reminder.reminderOpen
          })
            .selectedColor(Color.Green)
            .onChange((val) => {
              this.reminder.reminderOpen = val
            })
        }
        .backgroundColor(Color.Blue)
        .padding(4)
        .borderRadius(8)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .size({ width: '70%', height: '70%' })
      .alignItems(HorizontalAlign.Start)
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        center: { anchor: '__container__', align: VerticalAlign.Center }
      })
    }
  }

  getPermission(context: common.UIAbilityContext) {
    notificationManager.isNotificationEnabled().then((data: boolean) => {
      console.info(`isNotificationEnabled success, data: ${JSON.stringify(data)}`);
      if (!data) {
        notificationManager.requestEnableNotification(context).then(() => {
          console.info(`[ANS] requestEnableNotification success`);
        }).catch((err: BusinessError) => {
          if (1600004 === err.code) {
            console.error(`[ANS] requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
          } else {
            console.error(`[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      }
    }).catch((err: BusinessError) => {
      console.error(`isNotificationEnabled fail, code is ${err.code}, message is ${err.message}`);
    });
  }
}