
import 'package:flutter/material.dart';

import '../../models/patient_record.dart';

class FollowUPListItem extends StatelessWidget {


  FollowUPListItem({required this.followUp});

  final FollowUp followUp;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        Text(
          followUp.date +
              " : ",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black54),
        ),
        Text(
          followUp.text
          ,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(

          ),
        )
      ],
    );
  }
}