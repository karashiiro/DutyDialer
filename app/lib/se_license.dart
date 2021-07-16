import 'package:flutter/material.dart';

class SquareEnixLicenseInfo extends StatelessWidget {
  const SquareEnixLicenseInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            'FINAL FANTASY XIV © 2010-2021 SQUARE ENIX CO., LTD. All Rights Reserved.',
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }
}
