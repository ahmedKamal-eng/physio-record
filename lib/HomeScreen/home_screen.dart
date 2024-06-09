
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/AddRecordScreen/add_record_Screen.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_state.dart';
import 'package:physio_record/HomeScreen/widgets/record_card.dart';
import 'package:physio_record/global_vals.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Physio Record"),
      ),

      body: BlocBuilder<FetchRecordCubit,FetchRecordState>(builder: (BuildContext context, FetchRecordState state) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (context,index){
          return Padding(padding: EdgeInsets.all(10),
             child: RecordCard(patient: BlocProvider.of<FetchRecordCubit>(context).patientRecords![index],patientIndex: index,),
          );
        }
        ,itemCount:BlocProvider.of<FetchRecordCubit>(context).patientRecords!.length ,
        );
      },),
      // body:ListView.builder(
      //   physics: BouncingScrollPhysics(),
      //     itemBuilder: (context,index){
      //   return Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: RecordCard(patient: patients[index]),
      //   );
      // },itemCount: 10,),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>AddRecordScreen()));
          },
      ),
    );
  }
}
