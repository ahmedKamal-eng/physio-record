import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/widgets/record_card.dart';
import 'package:physio_record/models/patient_record.dart';

class RecordSearch extends SearchDelegate{


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: (){
        query="";
      }, icon: const Icon(Icons.clear)),
    ];
  }


  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: (){
      close(context, null);
    }, icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    List<PatientRecord>? patients=BlocProvider.of<FetchRecordCubit>(context).patientRecords;

    List<PatientRecord>? filteredList=[];

    if(query == "")
      {
        return Center(child: Text('search result'));
      }
    else
      {
        filteredList=patients!.where((element) => element.patientName.toLowerCase().startsWith(query.toLowerCase())).toList();
        return ListView.builder(itemBuilder: (context,index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: RecordCard(fromCenter:false,patient: filteredList![index], patientIndex: index, internetConnection: false),
          );
        },itemCount: filteredList.length,);
      }

  }
}