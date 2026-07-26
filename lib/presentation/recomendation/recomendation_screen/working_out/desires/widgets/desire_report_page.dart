import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/bloc/bloc.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../../../core/models/desire/desire.dart';
import '../../../../../../core/utils/image_constant.dart';
import 'desire_dialog.dart';
import 'desire_path_item.dart';
import 'desire_report_path.dart';


class DesireReportPage extends StatefulWidget {
  final List<Desire> desires;
  final List<Desire> executed;
  final List<Desire> inProcess;
  final List<Desire> expired;

  const DesireReportPage({Key? key, required this.desires, required this.executed, required this.inProcess, required this.expired}) : super(key: key);


  @override
  State<DesireReportPage> createState() => _DesireReportPageState();
}

class _DesireReportPageState extends State<DesireReportPage> with SingleTickerProviderStateMixin {

  late final tabController = TabController(length: 4, vsync: this);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController..addListener(() { 
      setState(() {
        
      });
    });
  }

  Widget _tab (String title, int index) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: index == tabController.index ? ColorConstant.blueGray400 : Colors.white
      ),
      padding: EdgeInsets.all(8),
      child: Tab(
        child: Text(title, style: AppStyle.txtSFProDisplayLight14.copyWith(color: index == tabController.index ? Colors.white : Colors.black),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
scrollDirection: Axis.vertical,      children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(aspectRatio: 3/1.5,
              child: Image.asset(ImageConstant.desireReportPNG, fit: BoxFit.fill,),
            ),
            SizedBox(height: 10,),
            CustomButton(
              width: double.infinity,
              onTap: () {
                context.read<DesiresBloc>().add(DesiresEvent.start());

              },
              text: 'start'.tr().toUpperCase(),

            ),

            SizedBox(height: 10,),],
        ),
      ),
        SizedBox(
          height: 40,
          child: Center(
            child: TabBar(
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.only(left: 10),
              isScrollable: true,
              indicatorColor: Colors.transparent,
                controller: tabController,
                tabs: [
              _tab('desires'.tr(), 0),
              _tab('executed_1'.tr(), 1),
              _tab('executing'.tr(), 2),
              _tab('desires_past'.tr(), 3),

            ]),
          ),
        ),
          SizedBox(height: 20,),
          DesireReportPath(desires: tabController.index == 0 ? widget.desires : tabController.index == 1 ? widget.executed : tabController.index == 2 ? widget.inProcess : widget.expired, onAdd: () {
    context.read<DesiresBloc>().add(DesiresEvent.start());
    }, buildWidget: (_) => DesirePathItem(desire: _, onTap: () {
      showDialog(context: context, builder: (_context) {
        return DesireDialog(desire: _, onTap: (){
          if(!_.completed && DateTime.now().isBefore(_.dateOfExecution)) {
                          Navigator.pop(_context);
                          context
                              .read<DesiresBloc>()
                              .add(DesiresEvent.execute(_));
                        }
                      },);
      });
          },),),

    ],);
  }
}
