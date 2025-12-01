
@Component
export default struct SettingButton {

  @Prop title: string;
  @Prop subTitle: string;

  @Consume pageInfos: NavPathStack = new NavPathStack();
  @State colorCode: string | undefined = AppStorage.get('selectedColorCode')
  @State colorName: string | undefined = AppStorage.get('selectedColorName')


  build() {

    if (this.title !== 'Reset') {


    Button({type: ButtonType.Capsule }){
      Row(){



        Row(){

          Stack(){
            Circle().fill('#ff666666').height(48).width(48)

            if(this.title !== 'Flash'){
              Circle().backgroundImage($r('app.media.spectrum')).backgroundImagePosition(Alignment.Center)
                .borderRadius(100).fill((this.colorName !== 'Custom') ? this.colorCode : Color.Transparent).height(35).width(35)

            } else {
              Image($r('app.media.sparkler')).backgroundImagePosition(Alignment.Center)
                .borderRadius(100).height(35).width(35)
            }

          }.height(55).width(55)


          Column(){
            Text(this.title).fontSize(21).fontColor(Color.White)
            Text(this.subTitle).fontSize(17).fontColor('#909090')
          }.alignItems(HorizontalAlign.Start)
          .margin({left:5})

        }


        Image($r('app.media.right_arrow')).width(40).height(40)

      }.width('96%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({left:7,right:7})

    }
    .width('92%')
    .height('120px')
    .fontSize('40px')
    .focusable(true)
    .focusOnTouch(true)
    .backgroundColor('#ff2b2b2b')
    .onClick(()=>{

      if (this.title !== 'Flash') {
        this.pageInfos.pushPathByName('ColorOptions',null,false);
      } else {
        this.pageInfos.pushPathByName('Flash',null,false);
      }

    })

    } else {

      Button('Reset')
        .type(ButtonType.Capsule)
        .backgroundColor('#b7172941')
        .fontColor('#699be4')
        .width('68%')
        .height('90px')
        .fontSize('30px')
        .onClick(()=>{
          this.pageInfos.pushPathByName('Reset',null,false)
        })


    }

  }
}