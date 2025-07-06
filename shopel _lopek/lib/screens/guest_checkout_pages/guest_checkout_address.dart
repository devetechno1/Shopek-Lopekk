import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/lang_text.dart';
import 'package:active_ecommerce_cms_demo_app/custom/loading.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/city_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/country_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/state_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/address_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/guest_checkout_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../custom/aiz_route.dart';
import '../../custom/input_decorations.dart';
import '../../custom/intl_phone_input.dart';
import '../checkout/shipping_info.dart';
import 'map_location.dart';

class GuestCheckoutAddress extends StatefulWidget {
  const GuestCheckoutAddress({Key? key, this.from_shipping_info = false})
      : super(key: key);
  final bool from_shipping_info;

  @override
  _GuestCheckoutAddressState createState() => _GuestCheckoutAddressState();
}

class _GuestCheckoutAddressState extends State<GuestCheckoutAddress> {
  final ScrollController _mainScrollController = ScrollController();

  int? _default_shipping_address = 0;
  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;
  double? longitude;
  double? latitude;
  bool passNotMatch = true;

  bool _isInitial = true;
  final List<dynamic> _shippingAddressList = [];

  String? name, email, address, country, state, city, postalCode, phone;
  String password = '';
  bool? emailValid;
  void setValues() {
    name = _nameController.text.trim();
    email = _emailController.text.trim();
    address = _addressController.text.trim();
    country = _selected_country!.id.toString();
    state = _selected_state!.id.toString();
    city = _selected_city!.id.toString();
    postalCode = _postalCodeController.text.trim();
    password = _passwordController.text;
  }

  //controllers for add purpose
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  //for update purpose
  final List<TextEditingController> _addressControllerListForUpdate = [];
  final List<TextEditingController> _postalCodeControllerListForUpdate = [];
  final List<TextEditingController> _phoneControllerListForUpdate = [];
  final List<TextEditingController> _cityControllerListForUpdate = [];
  final List<TextEditingController> _stateControllerListForUpdate = [];
  final List<TextEditingController> _countryControllerListForUpdate = [];
  final List<City?> _selected_city_list_for_update = [];
  final List<MyState?> _selected_state_list_for_update = [];
  final List<Country> _selected_country_list_for_update = [];

  bool _isValidPhoneNumber = false;

  List<String?> countries_code = <String?>[];
  Future<void> fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    fetch_country();

    if (is_logged_in.$) {
      fetchAll();
    }
  }

  fetchAll() {
    fetchShippingAddressList();

    setState(() {});
  }

  fetchShippingAddressList() async {
    // print("enter fetchShippingAddressList");
    final addressResponse = await AddressRepository().getAddressList();
    _shippingAddressList.addAll(addressResponse.addresses ?? []);
    setState(() {
      _isInitial = false;
    });
    if (_shippingAddressList.isNotEmpty) {
      // var count = 0;
      _shippingAddressList.forEach((address) {
        if (address.set_default == 1) {
          _default_shipping_address = address.id;
        }
        _addressControllerListForUpdate
            .add(TextEditingController(text: address.address));
        _postalCodeControllerListForUpdate
            .add(TextEditingController(text: address.postal_code));
        _phoneControllerListForUpdate
            .add(TextEditingController(text: address.phone));
        _countryControllerListForUpdate
            .add(TextEditingController(text: address.country_name));
        _stateControllerListForUpdate
            .add(TextEditingController(text: address.state_name));
        _cityControllerListForUpdate
            .add(TextEditingController(text: address.city_name));
        _selected_country_list_for_update
            .add(Country(id: address.country_id, name: address.country_name));
        _selected_state_list_for_update
            .add(MyState(id: address.state_id, name: address.state_name));
        _selected_city_list_for_update
            .add(City(id: address.city_id, name: address.city_name));
      });

      // print("fetchShippingAddressList");
    }

    setState(() {});
  }

  reset() {
    _default_shipping_address = 0;
    _shippingAddressList.clear();
    _isInitial = true;

    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();
    _passwordController.clear();

    longitude = null;
    latitude = null;
    passNotMatch = true;

    _countryController.clear();
    _stateController.clear();
    _cityController.clear();

    //update-ables
    _addressControllerListForUpdate.clear();
    _postalCodeControllerListForUpdate.clear();
    _phoneControllerListForUpdate.clear();
    _countryControllerListForUpdate.clear();
    _stateControllerListForUpdate.clear();
    _cityControllerListForUpdate.clear();
    _selected_city_list_for_update.clear();
    _selected_state_list_for_update.clear();
    _selected_country_list_for_update.clear();
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    if (is_logged_in.$) {
      fetchAll();
    }
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  afterAddingAnAddress() {
    reset();
    fetchAll();
  }

  afterDeletingAnAddress() {
    reset();
    fetchAll();
  }

  afterUpdatingAnAddress() {
    reset();
    fetchAll();
  }

  Future<void> onAddressSwitch(index) async {
    final addressMakeDefaultResponse =
        await AddressRepository().getAddressMakeDefaultResponse(index);

    if (addressMakeDefaultResponse.result == false) {
      ToastComponent.showDialog(
        addressMakeDefaultResponse.message,
      );
      return;
    }

    ToastComponent.showDialog(
      addressMakeDefaultResponse.message,
    );

    setState(() {
      _default_shipping_address = index;
    });
  }

  // onAddressAdd(context) async {
  //   var address = _addressController.text.toString();
  //   var postal_code = _postalCodeController.text.toString();
  //   var phone = _phoneController.text.toString();
  //
  //   if (address == "") {
  //     ToastComponent.showDialog(
  //       AppLocalizations.of(context)!.enter_address_ucf,
  //     );
  //     return;
  //   }
  //
  //   if (_selected_country == null) {
  //     ToastComponent.showDialog(
  //       AppLocalizations.of(context)!.select_a_country,
  //     );
  //     return;
  //   }
  //
  //   if (_selected_state == null) {
  //     ToastComponent.showDialog(
  //       AppLocalizations.of(context)!.select_a_state,
  //     );
  //     return;
  //   }
  //
  //   if (_selected_city == null) {
  //     ToastComponent.showDialog(
  //       AppLocalizations.of(context)!.select_a_city,
  //     );
  //     return;
  //   }
  //
  //   var addressAddResponse = await AddressRepository().getAddressAddResponse(
  //       address: address,
  //       country_id: _selected_country!.id,
  //       state_id: _selected_state!.id,
  //       city_id: _selected_city!.id,
  //       postal_code: postal_code,
  //       phone: phone);
  //
  //   if (addressAddResponse.result == false) {
  //     ToastComponent.showDialog(
  //       addressAddResponse.message,
  //     );
  //     return;
  //   }
  //
  //   ToastComponent.showDialog(
  //     addressAddResponse.message,
  //   );
  //
  //   Navigator.of(context, rootNavigator: true).pop();
  //   afterAddingAnAddress();
  // }
  bool requiredFieldVerification() {
    emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text.trim());

    if (_nameController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.name_required,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (_emailController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.email_required,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (!emailValid!) {
      ToastComponent.showDialog(LangText(context).local.enter_correct_email,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (longitude == null || latitude == null) {
      ToastComponent.showDialog(
          LangText(context).local.choose_an_address_or_pickup_point,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (_addressController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(
          LangText(context).local.shipping_address_required,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (_selected_country == null) {
      ToastComponent.showDialog(LangText(context).local.country_required,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (_selected_state == null) {
      ToastComponent.showDialog(LangText(context).local.state_required,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (_selected_city == null) {
      ToastComponent.showDialog(LangText(context).local.city_required,
          color: Theme.of(context).colorScheme.error);
      return false;
      // } else if (_postalCodeController.text.trim().toString().isEmpty) {
      //   ToastComponent.showDialog(
      //     LangText(context).local.postal_code_required,
      //     color: Theme.of(context).colorScheme.error,
      //   );
      //   return false;
    } else if (_phoneController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.phone_number_required,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (!_isValidPhoneNumber) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.invalid_phone_number,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (_passwordController.text.isEmpty) {
      ToastComponent.showDialog(LangText(context).local.enter_password,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (_passwordController.text.length < 6) {
      ToastComponent.showDialog(
          LangText(context).local.password_must_contain_at_least_6_characters,
          color: Theme.of(context).colorScheme.error);
      return false;
    } else if (passNotMatch) {
      ToastComponent.showDialog(LangText(context).local.passwords_do_not_match,
          color: Theme.of(context).colorScheme.error);
      return false;
    }
    return true;
  }

  Future<void> continueToDeliveryInfo() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!requiredFieldVerification()) return;

    Loading.show(context);
    setValues();

    final Map<String, String> postValue = {
      "email": email!,
      "phone": phone!,
    };

    var postBody = jsonEncode(postValue);
    final response =
        await GuestCheckoutRepository().guestCustomerInfoCheck(postBody);

    Loading.close();

    if (response.result!) {
      ToastComponent.showDialog(
        LangText(context).local.already_have_account,
        isError: true,
      );
    } else {
      postValue.addAll({
        "name": name!,
        "address": address!,
        "country_id": country!,
        "state_id": state!,
        "city_id": city!,
        "password": password,
        if (postalCode != null) "postal_code": postalCode!,
        if (longitude != null) "longitude": longitude!.toString(),
        if (latitude != null) "latitude": latitude!.toString(),
        "temp_user_id": temp_user_id.$,
      });

      postBody = jsonEncode(postValue);

      guestEmail.$ = email!;
      guestEmail.save();

      Navigator.of(context).pop();

      await AIZRoute.push(
        context,
        ShippingInfo(
          guestCheckOutShippingAddress: postBody,
        ),
      );
    }
  }

  void onSelectCountryDuringAdd(country, setModalState) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setModalState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setModalState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  void onSelectStateDuringAdd(state, setModalState) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setModalState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setModalState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  void onSelectCityDuringAdd(city, setModalState) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setModalState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setModalState(() {
      _cityController.text = city.name;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        bottomNavigationBar: buildBottomAppBar(context),
        body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          displacement: 0,
          child: CustomScrollView(
            controller: _mainScrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 05, 20, 16),
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.of(context).size.width - 16,
                    height: 90,
                    color: const Color(0xffFEF0D7),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSmall),
                        side: BorderSide(
                            color: Colors.amber.shade600, width: 1.0)),
                    child: Column(
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.add_new_address}",
                          style: TextStyle(
                              fontSize: 13,
                              color: MyTheme.dark_font_grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.add_sharp,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ],
                    ),
                    onPressed: () {
                      buildShowAddFormDialog(context);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: buildAddressList(),
                ),
                const SizedBox(
                  height: 100,
                )
              ]))
            ],
          ),
        ));
  }

// Alart Dialog
  Future buildShowAddFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusDefault),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              contentPadding: const EdgeInsets.only(
                top: 23.0,
                left: 20.0,
                right: 20.0,
                bottom: 2.0,
              ),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text(
                          "${AppLocalizations.of(context)!.name_ucf} *",
                          style: const TextStyle(
                            color: Color(0xff3E4447),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingNormal,
                        ),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _nameController,
                            autofocus: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: InputDecorations
                                .buildInputDecoration_with_border(
                              AppLocalizations.of(context)!.enter_your_name,
                            ),
                          ),
                        ),
                      ),

                      ////
                      //////////////////////////////////////////////email
                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text(
                            "${AppLocalizations.of(context)!.email_ucf} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _emailController,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecorations
                                .buildInputDecoration_with_border(
                                    AppLocalizations.of(context)!.enter_email),
                          ),
                        ),
                      ),
                      MapLocationWidget(
                        latitude: latitude,
                        longitude: longitude,
                        onPlacePicked: (latLong) {
                          latitude = latLong?.latitude;
                          longitude = latLong?.longitude;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text(
                            "${AppLocalizations.of(context)!.address_ucf} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _addressController,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecorations
                                .buildInputDecoration_with_border(
                                    AppLocalizations.of(context)!
                                        .enter_address_ucf),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text(
                            "${AppLocalizations.of(context)!.country_ucf} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            controller: _countryController,
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                textInputAction: TextInputAction.next,
                                obscureText: false,
                                decoration: InputDecorations
                                    .buildInputDecoration_with_border(
                                        AppLocalizations.of(context)!
                                            .enter_country_ucf),
                              );
                            },
                            suggestionsCallback: (name) async {
                              final countryResponse = await AddressRepository()
                                  .getCountryList(name: name);
                              return countryResponse.countries;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_countries_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic country) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  country.name,
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectCountryDuringAdd(value, setModalState);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text(
                            "${AppLocalizations.of(context)!.state_ucf} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            builder: (context, controller, focusNode) {
                              return TextField(
                                textInputAction: TextInputAction.next,
                                controller: controller,
                                focusNode: focusNode,
                                obscureText: false,
                                decoration: InputDecorations
                                    .buildInputDecoration_with_border(
                                        AppLocalizations.of(context)!
                                            .enter_state_ucf),
                              );
                            },
                            controller: _stateController,
                            suggestionsCallback: (name) async {
                              if (_selected_country == null) {
                                final stateResponse = await AddressRepository()
                                    .getStateListByCountry(); // blank response
                                return stateResponse.states;
                              }
                              final stateResponse = await AddressRepository()
                                  .getStateListByCountry(
                                      country_id: _selected_country!.id,
                                      name: name);
                              return stateResponse.states;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_states_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic state) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  state.name,
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectStateDuringAdd(value, setModalState);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text(
                            "${AppLocalizations.of(context)!.city_ucf} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            controller: _cityController,
                            suggestionsCallback: (name) async {
                              if (_selected_state == null) {
                                final cityResponse = await AddressRepository()
                                    .getCityListByState(); // blank response
                                return cityResponse.cities;
                              }
                              final cityResponse = await AddressRepository()
                                  .getCityListByState(
                                      state_id: _selected_state!.id,
                                      name: name);
                              return cityResponse.cities;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_cities_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic city) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  city.name,
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectCityDuringAdd(value, setModalState);
                            },
                            builder: (context, controller, focusNode) {
                              return TextField(
                                textInputAction: TextInputAction.next,
                                controller: controller,
                                focusNode: focusNode,
                                obscureText: false,
                                decoration: InputDecorations
                                    .buildInputDecoration_with_border(
                                        AppLocalizations.of(context)!
                                            .enter_city_ucf),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text(AppLocalizations.of(context)!.postal_code,
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TextField(
                            textInputAction: TextInputAction.next,
                            controller: _postalCodeController,
                            autofocus: false,
                            decoration: InputDecorations
                                .buildInputDecoration_with_border(
                                    AppLocalizations.of(context)!
                                        .enter_postal_code_ucf),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text(
                            "${AppLocalizations.of(context)!.phone_ucf} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusHalfSmall),
                          // boxShadow: [MyTheme.commonShadow()],
                        ),
                        height: 40,
                        child: CustomInternationalPhoneNumberInput(
                          countries: countries_code,
                          height: 40,
                          keyboardAction: TextInputAction.next,
                          backgroundColor: Colors.transparent,
                          hintText: LangText(context).local.phone_number_ucf,
                          errorMessage:
                              LangText(context).local.invalid_phone_number,
                          onInputChanged: (PhoneNumber number) {
                            setState(() {
                              if (number.isoCode != null)
                                AppConfig.default_country = number.isoCode!;
                              phone = number.phoneNumber ?? '';
                              print(phone);
                            });
                          },
                          onInputValidated: (bool value) {
                            print(value);
                            _isValidPhoneNumber = value;
                            setState(() {});
                          },
                          selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.DIALOG),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle:
                              const TextStyle(color: MyTheme.font_grey),
                          textStyle: const TextStyle(color: MyTheme.font_grey),
                          textFieldController: _phoneController,
                          formatInput: true,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true),
                          inputDecoration:
                              InputDecorations.buildInputDecoration_phone(
                                  hint_text: "01XXX XXX XXX"),
                          onSaved: (PhoneNumber number) {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text(
                            "${AppLocalizations.of(context)!.password_ucf} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TextField(
                            textInputAction: TextInputAction.next,
                            controller: _passwordController,
                            autofocus: false,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecorations
                                .buildInputDecoration_with_border(
                                    "• • • • • • • •"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text(
                            "${AppLocalizations.of(context)!.confirm_your_password} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TextField(
                            textInputAction: TextInputAction.done,
                            autofocus: false,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (val) {
                              passNotMatch = val != _passwordController.text;
                            },
                            decoration: InputDecorations
                                .buildInputDecoration_with_border(
                                    "• • • • • • • •"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusHalfSmall),
                            side: BorderSide(
                                color: MyTheme.light_grey, width: 1)),
                        child: Text(
                          LangText(context).local.close_ucf,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 1),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusHalfSmall),
                        ),
                        child: Text(
                          LangText(context).local.continue_ucf,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () async {
                          await continueToDeliveryInfo();
                        },
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
  }

  InputDecoration buildAddressInputDecoration(BuildContext context, hintText) {
    return InputDecoration(
        filled: true,
        fillColor: const Color(0xffF6F7F8),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 12.0, color: Color(0xff999999)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.noColor, width: 0.5),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDimensions.radiusHalfSmall),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.noColor, width: 1.0),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDimensions.radiusHalfSmall),
          ),
        ),
        contentPadding: const EdgeInsets.only(
            left: AppDimensions.paddingSmall, top: 6.0, bottom: 6.0));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_font_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.addresses_of_user,
            style: const TextStyle(
                fontSize: 16,
                color: Color(0xff3E4447),
                fontWeight: FontWeight.bold),
          ),
          Text(
            "* ${AppLocalizations.of(context)!.tap_on_an_address_to_make_it_default}",
            style: const TextStyle(fontSize: 12, color: Color(0xff6B7377)),
          ),
        ],
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget? buildAddressList() {
    // print("is Initial: ${_isInitial}");
    if (!is_logged_in.$ &&
        !AppConfig.businessSettingsData.guestCheckoutStatus) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.you_need_to_log_in,
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    } else if (_isInitial && _shippingAddressList.isEmpty) {
      if (AppConfig.businessSettingsData.guestCheckoutStatus) {
        return Center(
          child: Container(
            child: Text(
              AppLocalizations.of(context)!.no_address_is_added,
              style: const TextStyle(color: MyTheme.font_grey),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: ShimmerHelper().buildListShimmer(
          item_count: 5,
          item_height: 100.0,
        ),
      );
    } else if (_shippingAddressList.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 16,
            );
          },
          itemCount: _shippingAddressList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildAddressItemCard(index);
          },
        ),
      );
    } else if (!_isInitial && _shippingAddressList.isEmpty) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_address_is_added,
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    }
    return null;
  }

  GestureDetector buildAddressItemCard(index) {
    return GestureDetector(
      onTap: () {
        if (_default_shipping_address != _shippingAddressList[index].id) {
          onAddressSwitch(_shippingAddressList[index].id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
            border: Border.all(
                color:
                    _default_shipping_address == _shippingAddressList[index].id
                        ? Theme.of(context).primaryColor
                        : MyTheme.light_grey,
                width:
                    _default_shipping_address == _shippingAddressList[index].id
                        ? 1.0
                        : 0.0)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.address_ucf,
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 175,
                          child: Text(
                            _shippingAddressList[index].address,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.city_ucf,
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].city_name,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.state_ucf,
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].state_name,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.country_ucf,
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].country_name,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.postal_code,
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].postal_code,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.phone_ucf,
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].phone,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            app_language_rtl.$!
                ? Positioned(
                    left: 0.0,
                    top: 10.0,
                    child: showOptions(listIndex: index),
                  )
                : Positioned(
                    right: 0.0,
                    top: 10.0,
                    child: showOptions(listIndex: index),
                  ),
          ],
        ),
      ),
    );
  }

  Visibility buildBottomAppBar(BuildContext context) {
    return Visibility(
      visible: widget.from_shipping_info,
      child: BottomAppBar(
        color: Colors.transparent,
        child: Container(
          height: 50,
          child: Btn.minWidthFixHeight(
            minWidth: MediaQuery.of(context).size.width,
            height: 50,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: Text(
              AppLocalizations.of(context)!.back_to_shipping_info,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              return Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  Widget showOptions({listIndex, productId}) {
    return Container(
      width: 45,
      child: PopupMenuButton<MenuOptions>(
        offset: const Offset(-25, 0),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
            width: 45,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.topRight,
            child: Image.asset(AppImages.more,
                width: 4,
                height: 16,
                fit: BoxFit.contain,
                color: MyTheme.grey_153),
          ),
        ),
        onSelected: (MenuOptions result) {
          // setState(() {
          //   //_menuOptionSelected = result;
          // });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Edit,
            child: Text(AppLocalizations.of(context)!.edit_ucf),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Text(AppLocalizations.of(context)!.delete_ucf),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.AddLocation,
            child: Text(AppLocalizations.of(context)!.add_location_ucf),
          ),
        ],
      ),
    );
  }
}

enum MenuOptions { Edit, Delete, AddLocation }
