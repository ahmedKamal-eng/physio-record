
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/widgets/record_card.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
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
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    List<PatientRecord>? patients=BlocProvider.of<FetchRecordCubit>(context).patientRecords;


    List<PatientRecord>? filteredList=[];

    if(query =="")
      {
        return Center(child: Text('search result'));

      }

    else
      {
        filteredList=patients!.where((element) => element.patientName.toLowerCase().startsWith(query.toLowerCase())).toList();
        return ListView.builder(itemBuilder: (context,index){
          return RecordCard(patient: filteredList![index], patientIndex: index, internetConnection: false);
          // return GestureDetector(
          //   onTap: (){
          //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RecordDetailsScreen(patientRecord: filteredList![index])));
          //   },
          //   child: Card(child: Padding(
          //     padding: const EdgeInsets.all(18.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text('${filteredList![index].patientName}',style:Theme.of(context).textTheme.titleLarge,),
          //         Text('${filteredList![index].diagnosis}'),
          //       ],
          //     ),
          //   )),
          // );
        },itemCount: filteredList.length,);
      }

  }
}