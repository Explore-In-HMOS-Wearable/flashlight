import SettingButton from '../components/SettingButton';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, CircleShape, ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { BlinkSpeed } from '../model/BlinkSpeed';

interface CustomButtonType {
  title:string | undefined;
  subTitle:string | undefined;
}

@Builder
export function FlashlightSettingBuilder (){
  FlashlightSetting()
}

@Builder
function buildText() {
  Column() {
    Text('Flashlight settings')
      .fontSize('40px')
      .width('50%')
      .fontWeight(FontWeight.Bold)
       .fontColor(Color.White)
  }.margin(0)
}

@Component
struct FlashlightSetting {
  @Provide pageInfos: NavPathStack = new NavPathStack();

  @State colorName: string | undefined = AppStorage.get('selectedColorName')
  @State flashOption:string = ''


  @State options:CustomButtonType[] = [
    {title:'Color',subTitle:this.colorName},
    {title:'Flash',subTitle:this.getFlashType(this.flashOption)},
    {title:'Reset',subTitle:'None'}
  ]
  private watchSize: string = '466px';
  context: UIContext = this.getUIContext();
  tabBar1: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildText));


  getFlashType(flashOption: string) : string {

    const flashSetting : BlinkSpeed | undefined = AppStorage.get('flash')

    if (flashSetting === BlinkSpeed.SLOW) {

      flashOption = 'Slow';

    } else if (flashSetting === BlinkSpeed.FAST) {

      flashOption = 'Fast';

    } else {

      flashOption = 'None';

    }

    return flashOption;

  }

  @Builder
  buildList2() {
    Stack() {
      Column() {
      }
      .justifyContent(FlexAlign.Center)
      .width(this.watchSize)
      .height(this.watchSize)
      .clipShape(new CircleShape({ width: '100%', height: '100%' }))

      ArcList({ initialIndex: 0, header: this.tabBar1 }) {
        ForEach(this.options, (item: CustomButtonType) => {
          ArcListItem() {
            SettingButton({title:item.title, subTitle:item.subTitle})
          }.align(Alignment.Center)
        }, (item: CustomButtonType, index: number) => {return index + '_' + JSON.stringify(item.title); })
      }
      .space(LengthMetrics.px(10))
      .borderRadius(this.watchSize)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
    }
    .align(Alignment.Center)
    .width(this.watchSize)
    .height(this.watchSize)
    .border({color: Color.Black, width: 1})
    .borderRadius(this.watchSize)
  }


  build() {

    NavDestination() {

      Column(){

        this.buildList2()


      }.alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .height('100%')



    }.width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {

      this.pageInfos = context.pathStack;

    })

  }

}