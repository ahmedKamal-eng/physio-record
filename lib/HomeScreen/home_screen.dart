import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/AddRecordScreen/add_record_Screen.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_state.dart';
import 'package:physio_record/HomeScreen/widgets/record_card.dart';
import 'package:physio_record/SearchScreen/search_screen.dart';
import 'package:physio_record/global_vals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();

    _scrollController = ScrollController();
    // Optionally, you can jump to the start position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Physio Record"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Record Filter"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    DateTime? dateTime = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2024),
                                        lastDate: DateTime(2100));
                                    if (dateTime != null) {
                                      BlocProvider.of<FetchRecordCubit>(context)
                                          .filterPatientsByDate(dateTime);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text("choose specific day")),
                            ],
                          ),
                        );
                      });
                },
                icon: Icon(
                  Icons.tune_rounded,
                  size: 35,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: RecordSearch());
                },
                icon: const Icon(
                  Icons.search,
                  size: 35,
                )),
          ),
        ],
      ),

      body: BlocBuilder<FetchRecordCubit, FetchRecordState>(
        builder: (BuildContext context, FetchRecordState state) {
          return Column(
           mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (BlocProvider.of<FetchRecordCubit>(context).isFiltered)
                SizedBox(
                  height: MediaQuery.of(context).size.height *.1,
                  child: TextButton(onPressed: (){
                    BlocProvider.of<FetchRecordCubit>(context).clearFilter();
                  }, child: Text("Clear filter")),
                ),

              if (BlocProvider.of<FetchRecordCubit>(context).isFiltered)
                SizedBox(
                  height:BlocProvider.of<FetchRecordCubit>(context).filteredPatientRecords!.length <=3? MediaQuery.of(context).size.height * .4: MediaQuery.of(context).size.height * .7,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    reverse: true,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: RecordCard(
                          patient: BlocProvider.of<FetchRecordCubit>(context)
                              .filteredPatientRecords![index],
                          patientIndex: index,
                        ),
                      );
                    },
                    itemCount: BlocProvider.of<FetchRecordCubit>(context)
                        .filteredPatientRecords!
                        .length,
                  ),
                ),
              if (!BlocProvider.of<FetchRecordCubit>(context).isFiltered)
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    reverse: true,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: RecordCard(
                          patient: BlocProvider.of<FetchRecordCubit>(context)
                              .patientRecords![index],
                          patientIndex: index,
                        ),
                      );
                    },
                    itemCount: BlocProvider.of<FetchRecordCubit>(context)
                        .patientRecords!
                        .length,
                  ),
                )
            ],
          );
        },
      ),
      // body:ListView.builder(
      //   physics: BouncingScrollPhysics(),
      //     itemBuilder: (context,index){
      //   return Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: RecordCard(patient: patients[index]),
      //   );
      // },itemCount: 10,),

      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 10,
            backgroundColor: Colors.teal),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddRecordScreen()));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Record"),
            SizedBox(
              width: 15,
            ),
            Icon(Icons.person_add_alt_1_outlined)
          ],
        ),
      ),

      // FloatingActionButton(
      //
      //   child:WideIconButton(
      //     child: Text("Add Record") ,
      //     padding: 20,
      //   ),
      //   onPressed: (){

      //     },
      // ),
    );
  }
}

class WideIconButton extends StatelessWidget {
  final Widget child;
  final double padding;

  const WideIconButton({required this.child, this.padding = 8.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: child,
    );
  }
}
