import 'package:flutter/material.dart';
class HourlyForcast extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const HourlyForcast({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: 100,
        child:  Column(
          children: [
             Text(label,style:const  TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8,),
             Icon(
              icon,
              size: 32,
              ),
              const SizedBox(height: 8,),
              Text(value, 
              ),
          ],
        ),
      )
    );
  }
}