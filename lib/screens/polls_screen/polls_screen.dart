import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polmitra_admin/bloc/polls/polls_bloc.dart';
import 'package:polmitra_admin/bloc/polls/polls_event.dart';
import 'package:polmitra_admin/bloc/polls/polls_state.dart';
import 'package:polmitra_admin/models/poll.dart';
import 'package:polmitra_admin/utils/color_provider.dart';
import 'package:polmitra_admin/utils/text_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPolls();
  }

  void _loadPolls() {
    BlocProvider.of<PollBloc>(context).add(LoadPolls());
  }

  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PollBloc, PollState>(
        builder: (context, state) {
          if (state is PollLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PollsLoaded) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: state.polls.length,
                itemBuilder: (context, index) {
                  Poll poll = state.polls[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Container(
                        decoration: BoxDecoration(
                          color: ColorProvider.normalWhite,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: ColorProvider.darkGreyColor,
                              offset: const Offset(0.0, 1.5), //(x,y)
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: _buildPollCard(index, poll)),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text("Error loading polls"),
            );
          }
        },
      ),
    );
  }

  Widget _buildPollCard(int index, Poll poll) {
    final uploadedBy = poll.neta?.email ?? poll.netaId;

    return ListTile(
        title: TextBuilder.getText(text: poll.question, fontWeight: FontWeight.bold, fontSize: 16),
        subtitle: TextBuilder.getText(text: uploadedBy, fontWeight: FontWeight.normal, fontSize: 12),
        leading: TextBuilder.getText(text: "${index + 1}", fontWeight: FontWeight.bold, fontSize: 16),
        trailing: Switch(
          activeColor: Colors.blue,
          trackColor: MaterialStateColor.resolveWith((states) => Colors.grey),
          value: poll.isActive,
          onChanged: (value) {
            BlocProvider.of<PollBloc>(context).add(UpdatePollActiveStatus(poll.id, value));
          },
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return _showAdaptiveDialog(poll, uploadedBy);
            },
          );
        });
  }

  AlertDialog _showAdaptiveDialog(Poll poll, String uploadedBy) {
    var totalResponses = poll.responses.values.reduce((sum, element) => sum + element);

    return AlertDialog(
      title: TextBuilder.getText(text: poll.question, fontWeight: FontWeight.bold, fontSize: 16),
      content: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: "Active: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: poll.isActive ? "Yes" : "No",
                        style: TextStyle(color: poll.isActive ? Colors.green : Colors.red)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: "Uploaded By: ",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: uploadedBy,
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final scaffold = ScaffoldMessenger.of(context);
                            final mailtourl = 'mailto:$uploadedBy';
                            final uri = Uri.parse(mailtourl);
                            if (await canLaunchUrl(uri)) {
                              launchUrl(uri);
                            } else {
                              scaffold.showSnackBar(
                                  const SnackBar(content: Text("Could not launch email client")));
                            }
                          }),
                  ],
                ),
              ),

              /// totalResponses is the sum of all responses for the poll.
              TextBuilder.getText(
                text: "Total Responses: $totalResponses",
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              const SizedBox(height: 10),

              /// Display the options and their respective percentages.
              Column(
                  children: poll.options.map(
                        (option) {
                      final voteCount = poll.responses[option.toLowerCase()] ??
                          0; // Ensure option string matches response keys exactly.
                      final double percentage = totalResponses > 0 ? (voteCount / totalResponses) : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("$option: ${(percentage * 100).toStringAsFixed(2)}%"),
                          SizedBox(
                            height: 10,
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 10), // Spacing between bars
                        ],
                      );
                    },
                  ).toList())
            ]),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: TextBuilder.getText(text: "Close", fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );

  }
}
