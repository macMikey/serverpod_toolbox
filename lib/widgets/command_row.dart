import 'package:flutter/material.dart';
import 'package:serverpod_toolbox/widgets/info_popup_box.dart';

import 'copy_to_clipboard_button.dart';

///
/// A 'Command Row' widget to display the command description, play button, command to run, etc.
///
class CommandRow extends StatelessWidget {
    final BuildContext context;
    final String label;
    final String commandText;
    final Future<void> Function() onPlayPressed;
    final String infoHtmlBody;
    final bool isLoading;
    final String? secondaryCommandText;
    final Future<void> Function()? onSecondaryPlayPressed;

    ///
    /// Constructor for command row
    ///
    /// [label] is the text to display as the label.
    /// [commandText] is the text to display inside the black box.
    /// [onPlayPressed] is the callback function that will be invoked when the play button is pressed.
    /// [infoHtmlBody] is the HTML content to be displayed in the info popup.
    /// [isLoading] indicates whether a loading state is active.
    /// [secondaryCommandText] is the optional secondary command text.
    //  [onSecondaryPlayPressed] is the optional callback function for the secondary play button.
    //
    const CommandRow({
        super.key,
        required this.context,
        required this.label,
        required this.commandText,
        required this.onPlayPressed,
        required this.infoHtmlBody,
        required this.isLoading,
        this.secondaryCommandText,
        this.onSecondaryPlayPressed,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Row(
                    children: [
                        _buildLabel(),
                        _buildPlayButton(onPlayPressed),
                        const SizedBox(width: 5.0),
                        _buildCommandTextBox(commandText, onPlayPressed),
                        const SizedBox(width: 10.0),
                        CopyToClipboardButton(textToCopy: commandText),
                        _buildInfoIcon(),
                    ],
                ),
                if (secondaryCommandText != null) ...[
                    Row(
                        children: [
                            const Spacer(),
                            const SizedBox(width: 10.0),
                            _buildPlayButton(onSecondaryPlayPressed),
                            const SizedBox(width: 5.0),
                            _buildCommandTextBox(secondaryCommandText!, onSecondaryPlayPressed),
                            const SizedBox(width: 10.0),
                            CopyToClipboardButton(textToCopy: commandText),
                            const SizedBox(width: 40.0),
                        ],
                    ),
                ],
            ],
        );
    }

    ///
    /// Builds the label widget for the command row.
    ///
    /// The label is displayed with ellipsis overflow if it is too long.
    ///
    Widget _buildLabel() {
        return Expanded(
            child: Text(
                label,
                maxLines: 2,  // Adjust maxLines as needed
                overflow: TextOverflow.ellipsis,
            ),
        );
    }

    ///
    /// Builds the command text box/button widget.
    ///
    /// This widget displays the command text inside a styled container with a black background
    /// and white terminal font.  Clicking the box will run the command.
    ///
    Widget _buildCommandTextBox(String commandText, Future<void> Function()? onPressed) {
        return Tooltip(
            message: 'Click to run this command in the project',
            waitDuration: const Duration(seconds: 1),
        child:TextButton(
            onPressed: isLoading
            ? null
            : () async {
                // Trigger the play action
                await onPressed!();
            },
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: const BorderSide(
                        color: Colors.white,
                        width: 0.5,
                    ),
                ),
            ),
            child: Theme(
                data: ThemeData(
                    textSelectionTheme: const TextSelectionThemeData(
                        cursorColor: Colors.yellow,
                        selectionColor: Colors.blue,
                        selectionHandleColor: Colors.blue,
                    )),
                child: Text(
                    commandText,
                    style: TextStyle(
                        color: isLoading ? Colors.grey : Colors.white,
                        fontFamily: 'Fira Mono',
                    ),
                ),
            ),
        ),);
    }

    ///
    /// Builds the play button widget.
    ///
    /// This button is displayed as a green play arrow icon. When pressed, it triggers the [onPlayPressed]
    /// function and prevents multiple presses if [isLoading] is true.
    ///
    Widget _buildPlayButton(Future<void> Function()? onPressed) {
        return Tooltip(
            message: 'Click to run this command in the project',
            waitDuration: const Duration(seconds: 1), // Add this for the delay
            child: IconButton(
                icon: Icon(Icons.play_arrow, color: isLoading ? Colors.grey : Colors.green),
                onPressed: isLoading
                    ? null
                    : () async {
                    // Trigger the play action
                    await onPressed!();
                },
            ),
        );
    }


    ///
    /// Builds the info icon widget.
    ///
    /// This icon is displayed as an info outline icon. When pressed, it triggers the [showInfoPopup]
    /// function with the [commandText] and [infoHtmlBody].
    ///
    Widget _buildInfoIcon() {
        return IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoPopup(commandText, infoHtmlBody),
        );
    }

    ///
    /// Show the info popup
    ///
    void _showInfoPopup(String title, String content) {
        InfoPopupBox(
            context,
            title: title,
            htmlContent: content,
        ).show(context);
    }
}
