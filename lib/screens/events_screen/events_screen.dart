import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polmitra_admin/bloc/polmitra_event/pevent_bloc.dart';
import 'package:polmitra_admin/bloc/polmitra_event/pevent_event.dart';
import 'package:polmitra_admin/bloc/polmitra_event/pevent_state.dart';
import 'package:polmitra_admin/models/event.dart';
import 'package:polmitra_admin/screens/events_screen/event_details_screen.dart';
import 'package:polmitra_admin/utils/color_provider.dart';
import 'package:polmitra_admin/utils/text_builder.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  PersistentBottomSheetController? _eventBottomSheetController;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _fetchCurrentUser();
  }

  Future<void> _loadEvents() async {
    final bloc = context.read<EventBloc>();

    bloc.add(LoadEvents());
  }

  void _fetchCurrentUser() async {}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, PolmitraEventState>(
      builder: (context, state) {
        if (state is EventLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is EventsLoaded) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
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
                    child: _buildEventCard(event),
                  ),
                );
              },
            ),
          );
        } else if (state is EventError) {
          return Center(
            child: Text(state.message),
          );
        } else {
          return const Center(
            child: Text('Failed to load events'),
          );
        }
      },
    );
  }

  /// Event card widget
  Widget _buildEventCard(Event event) {
    return ListTile(
      title: TextBuilder.getText(
          text: event.eventName, fontWeight: FontWeight.bold, fontSize: 14, overflow: TextOverflow.ellipsis),
      subtitle: TextBuilder.getText(text: event.description, overflow: TextOverflow.ellipsis, fontSize: 12),

      /// leading image
      leading: SizedBox(
        width: 80,
        child: CachedNetworkImage(
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          imageUrl: event.images.isNotEmpty ? event.images.first : 'https://via.placeholder.com/150',
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),

      /// isActive switch
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          activeColor: Colors.blue,
          trackColor: MaterialStateColor.resolveWith((states) => Colors.grey),
          value: event.isActive,
          onChanged: (bool eventActiveStatus) {
            BlocProvider.of<EventBloc>(context).add(UpdateEventActiveStatus(event.id, eventActiveStatus));
          },
        ),
      ),

      /// on tap
      onTap: () => _showEventBottomSheet(event)
    );
  }

  void _showEventBottomSheet(Event event) {
    _eventBottomSheetController = showBottomSheet(
      context: context,
      builder: (context) {
        return EventDetailsScreen(event: event);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _eventBottomSheetController?.close();
  }
}
