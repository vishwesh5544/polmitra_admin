import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polmitra_admin/bloc/polls/polls_bloc.dart';
import 'package:polmitra_admin/bloc/polls/polls_event.dart';
import 'package:polmitra_admin/bloc/polls/polls_state.dart';
import 'package:polmitra_admin/models/poll.dart';
import 'package:polmitra_admin/screens/polls_screen/poll_details_screen.dart';
import 'package:polmitra_admin/utils/color_provider.dart';
import 'package:polmitra_admin/utils/text_builder.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  PersistentBottomSheetController? _pollBottomSheetController;

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
      onTap: () => _showPollDetailsBottomSheet(poll, uploadedBy),
    );
  }

  void _showPollDetailsBottomSheet(Poll poll, String uploadedBy) {
    _pollBottomSheetController = showBottomSheet(
      context: context,
      builder: (context) {
        return PollDetailsScreen(poll: poll, uploadedBy: uploadedBy);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pollBottomSheetController?.close();
  }
}
