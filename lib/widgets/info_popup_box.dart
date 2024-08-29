import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

///
/// Popup box for info text
///
class InfoPopupBox {
    final String title;
    final String htmlContent;

    InfoPopupBox(BuildContext context, {required this.title, required this.htmlContent});

    Future<void> show(BuildContext context) async {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
                return Dialog(
                    child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child:  SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10.0),
                                    SingleChildScrollView(
                                        child: Html(
                                            data: htmlContent,
                                        ),
                                    ),

                                    const SizedBox(height: 10.0),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                    ),
                                ],
                            ),
                        ),
                    ),
                );
            },
        );
    }


}
