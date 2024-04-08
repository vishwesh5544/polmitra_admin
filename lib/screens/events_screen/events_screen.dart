import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polmitra_admin/bloc/polmitra_event/pevent_bloc.dart';
import 'package:polmitra_admin/bloc/polmitra_event/pevent_event.dart';
import 'package:polmitra_admin/bloc/polmitra_event/pevent_state.dart';
import 'package:polmitra_admin/models/event.dart';
import 'package:polmitra_admin/utils/color_provider.dart';
import 'package:polmitra_admin/utils/text_builder.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
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
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: (context) {
            return _showAdaptiveDialog(event);
          },
        );
        // navigate to event details screen
      },
    );
  }

  /// Show adaptive dialog
  AlertDialog _showAdaptiveDialog(Event event) {
    return AlertDialog(
      backgroundColor: ColorProvider.normalWhite,
      title: TextBuilder.getText(text: event.eventName, fontWeight: FontWeight.bold, fontSize: 25),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// description
            TextBuilder.getText(text: "Description:", fontSize: 18, fontWeight: FontWeight.bold),
            const SizedBox(height: 3),
            SizedBox(
              height: 80,
              child:SingleChildScrollView(
                  child: TextBuilder.getText(text: event.description, fontSize: 18, overflow: TextOverflow.visible),
              ),
            ),
            const SizedBox(height: 10),

            /// date
            RichText(
              text: TextSpan(
                children: [
                   TextSpan(
                    text: "Date: ",
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                  ),
                  TextSpan(
                    text: event.date,
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            /// time
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Time: ",
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                  ),
                  TextSpan(
                    text: event.time,
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            /// location
            RichText(
              text: TextSpan(
                children: [
                   TextSpan(
                    text: "Location: ",
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                  ),
                  TextSpan(
                    text: event.location,
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            /// neta
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Neta: ",
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                  ),
                  TextSpan(
                    text: event.neta?.email ?? event.netaId,
                    style: TextBuilder.getTextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            /// images carousel
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: event.images.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                              imageUrl: image,
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
