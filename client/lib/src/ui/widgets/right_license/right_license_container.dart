import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_room/src/bloc/playlist/playlist_bloc.dart';
import 'package:music_room/src/bloc/right_license/right_license_bloc.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/right_license_time.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/ui/widgets/button.dart';
import 'package:music_room/src/ui/widgets/switch_input.dart';
import 'package:music_room/utils/place_picker/lib/widgets/place_picker.dart';
import 'package:vrouter/src/core/extended_context.dart';

class RightLicenseContainer extends StatefulWidget {
  const RightLicenseContainer({
    Key? key,
    required this.roomRepository,
    required this.playlistRepository,
    required this.initialRightLicense,
    required this.uid,
    required this.closeFunc,
    required this.onUpdateRightLicenseFunc,
    this.isRoom = true,
  }) : super(key: key);
  final RoomRepository? roomRepository;
  final PlaylistRepository? playlistRepository;
  final RightLicense initialRightLicense;
  final String uid;
  final void Function()? closeFunc;
  final Function(RightLicense license) onUpdateRightLicenseFunc;
  final bool isRoom;

  @override
  _RightLicenseContainerState createState() => _RightLicenseContainerState();
}

class _RightLicenseContainerState extends State<RightLicenseContainer> {
  bool _isScrollable = true;
  final TextEditingController _timeRestrictionStartFieldControllerKey =
      TextEditingController();
  final FocusNode _timeRestrictionStartFieldNode = FocusNode();
  final TextEditingController _timeRestrictionEndFieldControllerKey =
      TextEditingController();
  final FocusNode _timeRestrictionEndFieldFieldNode = FocusNode();

  String _formatFromTimeOfDay(TimeOfDay? time) {
    if (time != null) {
      return ("${time.hour.toString()}h${time.minute.toString()}");
    }
    return ("");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RightLicenseBloc(
          playlistRepository: widget.playlistRepository,
          roomRepository: widget.roomRepository,
          initial: widget.initialRightLicense.toRightLicenseState()),
      child: BlocListener<RightLicenseBloc, RightLicenseState>(
        listener: (context, state) {
          if (state.status == true) {
            widget.onUpdateRightLicenseFunc(RightLicense(
                location: state.locationRestriction != null
                    ? GeoPoint(state.locationRestriction!.latLng!.latitude,
                        state.locationRestriction!.latLng!.longitude)
                    : widget.initialRightLicense.location,
                timeEnabled:
                    state.timeEnabled ?? widget.initialRightLicense.timeEnabled,
                locationEnabled: state.locationEnabled ??
                    widget.initialRightLicense.locationEnabled,
                onlyInvitedEnabled: state.onlyInvitedEnabled ??
                    widget.initialRightLicense.onlyInvitedEnabled,
                time: RightLicenseTime(
                  start: state.timeRestrictionStart != null
                      ? state.timeRestrictionStart!.hour * 60 +
                          state.timeRestrictionStart!.minute
                      : widget.initialRightLicense.time.start,
                  end: state.timeRestrictionEnd != null
                      ? state.timeRestrictionEnd!.hour * 60 +
                          state.timeRestrictionEnd!.minute
                      : widget.initialRightLicense.time.end,
                )));
            widget.closeFunc!();
          } else if (state.status == false && state.error.isNotEmpty) {
            context.read<RightLicenseBloc>().add(RightLicenseResetError());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 5),
                content: Text(state.error, style: TextStyle(color: Colors.red)),
              ),
            );
          }
        },
        child: BlocBuilder<RightLicenseBloc, RightLicenseState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics:
                  _isScrollable == true ? null : NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: IconButton(
                          onPressed: widget.closeFunc,
                          icon: Icon(Icons.close,
                              size: 40, color: Colors.black38)),
                    ),
                  ),
                  if (!widget.isRoom) SizedBox(height: 130),
                  SwitchInput(
                    onChangedFunc: (data) {
                      context.read<RightLicenseBloc>().add(
                            RightLicenseUpdateVoteOnlyInvited(data),
                          );
                    },
                    label: widget.isRoom
                        ? "Who can vote : "
                        : "Who can add song : ",
                    trueValue: "only invited",
                    falseValue: "everyone   ",
                    value: context
                            .read<RightLicenseBloc>()
                            .state
                            .onlyInvitedEnabled ??
                        false,
                    width: widget.isRoom ? 294 : 334,
                    switchPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  ),
                  if (widget.isRoom == true)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Divider(
                            height: 5,
                            color: Colors.grey,
                          ),
                        ),
                        SwitchInput(
                          onChangedFunc: (data) {
                            context.read<RightLicenseBloc>().add(
                                  RightLicenseUpdateRestrictionVoteTime(data),
                                );
                          },
                          label: "Restriction vote time ",
                          trueValue: "         ",
                          falseValue: "         ",
                          value: context
                                  .read<RightLicenseBloc>()
                                  .state
                                  .timeEnabled ??
                              false,
                          width: 294,
                          switchPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 98,
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: TextFormField(
                                readOnly: true,
                                key: Key("voteTimeStartRestriction"),
                                controller:
                                    _timeRestrictionStartFieldControllerKey
                                      ..text = _formatFromTimeOfDay(context
                                          .read<RightLicenseBloc>()
                                          .state
                                          .timeRestrictionStart),
                                focusNode: _timeRestrictionStartFieldNode,
                                onTap: () async {
                                  _timeRestrictionStartFieldNode.unfocus();
                                  final res = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        const TimeOfDay(hour: 10, minute: 47),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (res != null) {
                                    context.read<RightLicenseBloc>().add(
                                        RightLicenseUpdateVoteStartRestriction(
                                            res));
                                  }
                                },
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade700,
                                        width: 1.0),
                                  ),
                                  filled: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(25, 0, 5, 0),
                                  fillColor: Colors.black26,
                                  labelStyle: TextStyle(color: Colors.white),
                                  errorStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400),
                                  labelText: 'Start',
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Container(
                              width: 98,
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: TextFormField(
                                readOnly: true,
                                key: Key("voteTimeEndRestriction"),
                                controller:
                                    _timeRestrictionEndFieldControllerKey
                                      ..text = _formatFromTimeOfDay(context
                                          .read<RightLicenseBloc>()
                                          .state
                                          .timeRestrictionEnd),
                                focusNode: _timeRestrictionEndFieldFieldNode,
                                onTap: () async {
                                  _timeRestrictionEndFieldFieldNode.unfocus();
                                  final res = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        const TimeOfDay(hour: 10, minute: 47),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (res != null) {
                                    context.read<RightLicenseBloc>().add(
                                        RightLicenseUpdateVoteEndRestriction(
                                            res));
                                  }
                                },
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade700,
                                        width: 1.0),
                                  ),
                                  filled: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(25, 0, 5, 0),
                                  fillColor: Colors.black26,
                                  labelStyle: TextStyle(color: Colors.white),
                                  errorStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400),
                                  labelText: 'End',
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Divider(
                            height: 5,
                            color: Colors.grey,
                          ),
                        ),
                        SwitchInput(
                          onChangedFunc: (data) {
                            context.read<RightLicenseBloc>().add(
                                  RightLicenseUpdateRestrictionVoteLocation(
                                      data),
                                );
                          },
                          label: "Restriction vote location ",
                          trueValue: "  ",
                          falseValue: "  ",
                          value: context
                                  .read<RightLicenseBloc>()
                                  .state
                                  .locationEnabled ??
                              false,
                          width: 294,
                          switchPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                        ),
                        Text(
                          "only people near to this location can vote",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        GestureDetector(
                          onTapDown: (data) {
                            setState(() {
                              _isScrollable = false;
                            });
                          },
                          onTapUp: (data) {
                            setState(() {
                              _isScrollable = true;
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              _isScrollable = true;
                            });
                          },
                          child: Container(
                            height: 300,
                            width: 290,
                            child: PlacePicker(
                              'API_KEY',
                              displayLocation: LatLng(
                                  widget.initialRightLicense.location.latitude,
                                  widget
                                      .initialRightLicense.location.longitude),
                              updateLocation: (location) {
                                if (location != null) {
                                  context.read<RightLicenseBloc>().add(
                                      RightLicenseUpdateLocalisationRestriction(
                                          location));
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(6, widget.isRoom ? 12 : 50, 0, 8),
                    child: Button(
                        text: "Update",
                        buttonKey: Key("RightLicenseKey"),
                        onSubmitFunc: () {
                          context.read<RightLicenseBloc>().add(
                              RightLicenseSendUpdate(
                                  widget.uid)); // GET ID OF ROOM OR PLAYLIST
                        },
                        isEnabled: state.buttonStatus),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
