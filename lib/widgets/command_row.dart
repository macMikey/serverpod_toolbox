import 'package:flutter/material.dart';
import 'package:serverpod_toolbox/info_box.dart';

///
/// A generic 'Command Row' widget
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
                        const Spacer(),
                        _buildCommandTextBox(commandText),
                        const SizedBox(width: 10.0),
                        _buildPlayButton(onPlayPressed),
                        _buildInfoIcon(),
                    ],
                ),
                if (secondaryCommandText != null) ...[
                    Row(
                        children: [
                            const Spacer(),
                            const SizedBox(width: 10.0),
                            _buildCommandTextBox(secondaryCommandText!),
                            const SizedBox(width: 10.0),
                            _buildPlayButton(onSecondaryPlayPressed),
                            const SizedBox(width: 40.0),
                        ],
                    ),
                ],
            ],
        );
    }

    ///
    /// Build the label widget for the command row.
    ///
    /// The label is displayed with ellipsis overflow if it is too long.
    ///
    Widget _buildLabel() {
        return Text(
            label,
            maxLines: 2,
            // overflow: TextOverflow.ellipsis,
        );
    }

    ///
    /// Build the command text box widget.
    ///
    /// This widget displays the command text inside a styled container with a black background
    /// and white terminal font.
    ///
    Widget _buildCommandTextBox(String commandText) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4.0),
            ),
            child: Theme(
                data: ThemeData(
                    textSelectionTheme: const TextSelectionThemeData(
                        cursorColor: Colors.yellow,
                        selectionColor: Colors.blue,
                        selectionHandleColor: Colors.blue,
                    )),
                child: SelectableText(
                    commandText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Fira Mono', // Or a similar terminal font
                    ),
                ),
            ),
        );
    }

    ///
    /// Build the play button widget.
    ///
    /// This button is displayed as a green play arrow icon. When pressed, it triggers the [onPlayPressed]
    /// function and prevents multiple presses if [isLoading] is true.
    ///
    Widget _buildPlayButton(Future<void> Function()? onPressed) {
        return IconButton(
            icon: Icon(Icons.play_arrow, color: isLoading ? Colors.grey : Colors.green),
            onPressed: isLoading
            ? null
            : () async {
                // Trigger the play action
                await onPressed!();
            },
        );
    }

    ///
    /// Build the info icon widget.
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
