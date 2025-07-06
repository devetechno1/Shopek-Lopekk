import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/lang_text.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/city_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/country_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/state_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/address_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/map_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../app_config.dart';
import '../custom/input_decorations.dart';
import '../custom/intl_phone_input.dart';
import '../data_model/address_response.dart' as res;

class Address extends StatefulWidget {
  const Address({Key? key, this.from_shipping_info = false}) : super(key: key);
  final bool from_shipping_info;

  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  final ScrollController _mainScrollController = ScrollController();

  int? _default_shipping_address = 0;

  bool _isInitial = true;
  final List<res.Address> _shippingAddressList = [];

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  Future fetchAll() async {
    await fetchShippingAddressList();

    setState(() {});
  }

  Future fetchShippingAddressList() async {
    // print("enter fetchShippingAddressList");
    final res.AddressResponse addressResponse =
        await AddressRepository().getAddressList();
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
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  Future afterAddingAnAddress() async {
    reset();
    await fetchAll();
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

  onPressDelete(id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context)!
                      .are_you_sure_to_remove_this_address,
                  maxLines: 3,
                  style:
                      const TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                Btn.basic(
                  child: Text(
                    AppLocalizations.of(context)!.cancel_ucf,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                Btn.basic(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    AppLocalizations.of(context)!.confirm_ucf,
                    style: TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    confirmDelete(id);
                  },
                ),
              ],
            ));
  }

  Future<void> confirmDelete(id) async {
    final addressDeleteResponse =
        await AddressRepository().getAddressDeleteResponse(id);

    if (addressDeleteResponse.result == false) {
      ToastComponent.showDialog(
        addressDeleteResponse.message,
      );
      return;
    }

    ToastComponent.showDialog(
      addressDeleteResponse.message,
    );

    afterDeletingAnAddress();
  }

  _tabOption(int index, int listIndex) {
    switch (index) {
      case 0:
        buildShowUpdateFormDialog(context, listIndex);
        break;
      case 1:
        onPressDelete(_shippingAddressList[listIndex].id);
        break;
      case 2:
        _choosePlace(_shippingAddressList[listIndex]);
        //deleteProduct(productId);
        break;
      default:
        break;
    }
  }

  void _choosePlace(res.Address address) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MapLocation(address: address);
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
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
        builder: (context) {
          return AddAddressDialog(
            shippingAddressList: _shippingAddressList,
            afterAddingAnAddress: afterAddingAnAddress,
            choosePlace: (index) => _choosePlace(_shippingAddressList[index]),
          );
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
        contentPadding: const EdgeInsetsDirectional.only(
            start: 8.0, top: 6.0, bottom: 6.0));
  }

  Future buildShowUpdateFormDialog(BuildContext context, index) {
    return showDialog(
        context: context,
        builder: (context) {
          return EditAddressDialog(
            shippingAddress: _shippingAddressList[index],
            afterUpdatingAnAddress: afterUpdatingAnAddress,
            selected_city: _selected_city_list_for_update[index],
            selected_state: _selected_state_list_for_update[index],
            selected_country: _selected_country_list_for_update[index],
            addressControllerText: _addressControllerListForUpdate[index].text,
            postalCodeControllerText:
                _postalCodeControllerListForUpdate[index].text,
            phoneControllerText: _shippingAddressList[index].phone ?? '',
            cityControllerText: _cityControllerListForUpdate[index].text,
            stateControllerText: _stateControllerListForUpdate[index].text,
            countryControllerText: _countryControllerListForUpdate[index].text,
          );
        });
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
    if (is_logged_in == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.you_need_to_log_in,
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    } else if (_isInitial && _shippingAddressList.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
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

  InkWell buildAddressItemCard(int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
      onTap: () {
        if (_shippingAddressList[index].location_available != true) {
          _choosePlace(_shippingAddressList[index]);
          // ToastComponent.showDialog(AppLocalizations.of(context)!.you_have_to_add_location_first,isError: true,gravity: ToastGravity.BOTTOM);
          return;
        }
        if (_default_shipping_address != _shippingAddressList[index].id) {
          onAddressSwitch(_shippingAddressList[index].id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
              padding: const EdgeInsets.all(AppDimensions.paddingDefault)
                  .copyWith(bottom: AppDimensions.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LineData(
                    name: AppLocalizations.of(context)!.address_ucf,
                    body: "${_shippingAddressList[index].address}",
                  ),
                  LineData(
                    name: AppLocalizations.of(context)!.city_ucf,
                    body: "${_shippingAddressList[index].city_name}",
                  ),
                  LineData(
                    name: AppLocalizations.of(context)!.state_ucf,
                    body: "${_shippingAddressList[index].state_name}",
                  ),
                  LineData(
                    name: AppLocalizations.of(context)!.country_ucf,
                    body: "${_shippingAddressList[index].country_name}",
                  ),
                  LineData(
                    name: AppLocalizations.of(context)!.postal_code,
                    body: "${_shippingAddressList[index].postal_code}",
                  ),
                  LineData(
                    name: AppLocalizations.of(context)!.phone_ucf,
                    body: "${_shippingAddressList[index].phone}",
                  ),
                  _shippingAddressList[index].location_available != true
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                bottom: AppDimensions.paddingSmall),
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 9),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusHalfSmall)),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .you_have_to_add_location_here,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            LineData(
                              name: AppLocalizations.of(context)!.latitude,
                              body: "${_shippingAddressList[index].lat}",
                            ),
                            LineData(
                              name: AppLocalizations.of(context)!.longitude,
                              body: "${_shippingAddressList[index].lang}",
                            ),
                          ],
                        ),
                ],
              ),
            ),
            // app_language_rtl.$!
            // ?
            PositionedDirectional(
              end: 0.0,
              top: 20,
              child: showOptions(listIndex: index),
            )
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

  Widget showOptions({required int listIndex, int? productId}) {
    return PopupMenuButton<MenuOptions>(
      offset: const Offset(-25, 0),
      child: Container(
        width: 45,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: AlignmentDirectional.topEnd,
        child: Image.asset(AppImages.more,
            width: 4, height: 16, fit: BoxFit.contain, color: MyTheme.grey_153),
      ),
      onSelected: (MenuOptions result) {
        _tabOption(result.index, listIndex);
        // setState(() {
        //   //_menuOptionSelected = result;
        // });
      },
      position: PopupMenuPosition.under,
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
          child: Text(AppLocalizations.of(context)!.edit_location),
        ),
      ],
    );
  }
}

class LineData extends StatelessWidget {
  const LineData({super.key, required this.name, required this.body});

  final String name;
  final String? body;

  @override
  Widget build(BuildContext context) {
    if (body?.isNotEmpty != true) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              name,
              style: const TextStyle(
                  color: Color(0xff6B7377), fontWeight: FontWeight.normal),
            ),
          ),
          Flexible(
            child: Text(
              body!,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

enum MenuOptions { Edit, Delete, AddLocation }

class AddAddressDialog extends StatefulWidget {
  const AddAddressDialog({
    super.key,
    required this.shippingAddressList,
    required this.afterAddingAnAddress,
    required this.choosePlace,
  });

  final List<dynamic> shippingAddressList;
  final Future<void> Function() afterAddingAnAddress;
  final void Function(int) choosePlace;

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;

  //controllers for add purpose
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String _phone = "";
  bool _isValidPhoneNumber = false;
  List<String?> countries_code = <String?>[];
  PhoneNumber initialValue = PhoneNumber(isoCode: AppConfig.default_country);

  Future<void> fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  Future<void> getInitVal() async {
    _phone = user_phone.$.trim();
    initialValue = await PhoneNumber.getRegionInfoFromPhoneNumber(_phone);
    _phoneController.text = initialValue.parseNumber().replaceAll("+", '');
    _isValidPhoneNumber = _phoneController.text.isNotEmpty;
    setState(() {});
  }

  void reset() {
    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();
    _countryController.clear();
    _stateController.clear();
    _cityController.clear();
  }

  Future<void> _onAddressAdd() async {
    final String address = _addressController.text.toString();
    final String postalCode = _postalCodeController.text.toString();
    // var phone = _phoneController.text.toString();

    if (address.trim() == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_address_ucf,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_selected_country == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.select_a_country,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_selected_state == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.select_a_state,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_selected_city == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.select_a_city,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_phone.trim().isEmpty) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          color: Theme.of(context).colorScheme.error);
      return;
    } else if (!_isValidPhoneNumber) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.invalid_phone_number,
          color: Theme.of(context).colorScheme.error);
      return;
    }

    final addressAddResponse = await AddressRepository().getAddressAddResponse(
        address: address,
        country_id: _selected_country!.id,
        state_id: _selected_state!.id,
        city_id: _selected_city!.id,
        postal_code: postalCode,
        phone: _phone);

    if (addressAddResponse.result == false) {
      ToastComponent.showDialog(
        addressAddResponse.message,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    ToastComponent.showDialog(
      addressAddResponse.message,
      color: Colors.green,
    );

    Navigator.of(context, rootNavigator: true).pop();
    await widget.afterAddingAnAddress();
    final int i = widget.shippingAddressList.length - 1;
    widget.choosePlace(i);
  }

  void onSelectCountryDuringAdd(country) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  void onSelectStateDuringAdd(state) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  void onSelectCityDuringAdd(City city) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setState(() {
        _cityController.text = city.name!;
      });
      return;
    }
    _selected_city = city;
    setState(() {
      _cityController.text = city.name!;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitVal();
    fetch_country();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusDefault)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      contentPadding: const EdgeInsets.only(
          top: AppDimensions.paddingLarge,
          left: AppDimensions.paddingLarge,
          right: AppDimensions.paddingLarge,
          bottom: 2.0),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingSmallExtra),
                child: Text("${AppLocalizations.of(context)!.address_ucf} *",
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _addressController,
                    autofocus: false,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration:
                        InputDecorations.buildInputDecoration_with_border(
                            AppLocalizations.of(context)!.enter_address_ucf),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.country_ucf} *",
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    controller: _countryController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                AppLocalizations.of(context)!
                                    .enter_country_ucf),
                      );
                    },
                    suggestionsCallback: (name) async {
                      final countryResponse =
                          await AddressRepository().getCountryList(name: name);
                      return countryResponse.countries;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_countries_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic country) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          country.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (value) => onSelectCountryDuringAdd(value),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.state_ucf} *",
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                AppLocalizations.of(context)!.enter_state_ucf),
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
                              country_id: _selected_country!.id, name: name);
                      return stateResponse.states;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_states_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic state) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          state.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (value) => onSelectStateDuringAdd(value),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.city_ucf} *",
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    controller: _cityController,
                    suggestionsCallback: (name) async {
                      if (_selected_state == null) {
                        final CityResponse cityResponse =
                            await AddressRepository()
                                .getCityListByState(); // blank response
                        return cityResponse.cities;
                      }
                      final CityResponse cityResponse =
                          await AddressRepository().getCityListByState(
                              state_id: _selected_state!.id, name: name);
                      return cityResponse.cities;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_cities_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic city) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          city.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (value) => onSelectCityDuringAdd(value),
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                AppLocalizations.of(context)!.enter_city_ucf),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.phone_ucf} *",
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                  // boxShadow: [MyTheme.commonShadow()],
                ),
                height: 40,
                child: CustomInternationalPhoneNumberInput(
                  countries: countries_code,
                  height: 40,
                  backgroundColor: Colors.transparent,
                  hintText: LangText(context).local.phone_number_ucf,
                  errorMessage: LangText(context).local.invalid_phone_number,
                  initialValue: initialValue,
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      if (number.isoCode != null)
                        AppConfig.default_country = number.isoCode!;
                      _phone = number.phoneNumber ?? '';
                      print(_phone);
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
                  selectorTextStyle: const TextStyle(color: MyTheme.font_grey),
                  textStyle: const TextStyle(color: MyTheme.font_grey),
                  textFieldController: _phoneController,
                  formatInput: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  inputDecoration: InputDecorations.buildInputDecoration_phone(
                      hint_text: "01XXX XXX XXX"),
                  onSaved: (PhoneNumber number) {},
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text(AppLocalizations.of(context)!.postal_code,
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _postalCodeController,
                    autofocus: false,
                    decoration:
                        InputDecorations.buildInputDecoration_with_border(
                            AppLocalizations.of(context)!
                                .enter_postal_code_ucf),
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
            Btn.minWidthFixHeight(
              minWidth: 75,
              height: 40,
              color: const Color.fromRGBO(253, 253, 253, 1),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                  side: BorderSide(color: MyTheme.light_grey, width: 1)),
              child: Text(
                LangText(context).local.close_ucf,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            const SizedBox(width: 1),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: AppDimensions.paddingDefault),
              child: Btn.minWidthFixHeight(
                minWidth: 75,
                height: 40,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                ),
                child: Text(
                  LangText(context).local.continue_ucf,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _onAddressAdd,
              ),
            )
          ],
        )
      ],
    );
  }
}

class EditAddressDialog extends StatefulWidget {
  const EditAddressDialog({
    super.key,
    required this.shippingAddress,
    required this.afterUpdatingAnAddress,
    required this.selected_city,
    required this.selected_state,
    required this.selected_country,
    required this.addressControllerText,
    required this.postalCodeControllerText,
    required this.phoneControllerText,
    required this.cityControllerText,
    required this.stateControllerText,
    required this.countryControllerText,
  });
  final shippingAddress;
  final City? selected_city;
  final MyState? selected_state;
  final Country? selected_country;
  final String addressControllerText;
  final String postalCodeControllerText;
  final String phoneControllerText;
  final String cityControllerText;
  final String stateControllerText;
  final String countryControllerText;

  final void Function() afterUpdatingAnAddress;

  @override
  State<EditAddressDialog> createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;

  late City? _selected_city = widget.selected_city;
  late MyState? _selected_state = widget.selected_state;
  late Country? _selected_country = widget.selected_country;

  String _phone = "";
  bool _isValidPhoneNumber = false;
  List<String?> countries_code = <String?>[];
  PhoneNumber initialValue = PhoneNumber(isoCode: AppConfig.default_country);

  Future<void> fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  Future<void> getSavedPhone(String phone) async {
    _phone = phone.trim();
    initialValue = await PhoneNumber.getRegionInfoFromPhoneNumber(_phone);
    _phoneController.text = initialValue.parseNumber().replaceAll("+", '');
    _isValidPhoneNumber = _phoneController.text.isNotEmpty;
  }

  Future<void> getInitVal() async {
    _addressController =
        TextEditingController(text: widget.addressControllerText);
    _postalCodeController =
        TextEditingController(text: widget.postalCodeControllerText);
    _phoneController = TextEditingController(text: widget.phoneControllerText);
    _cityController = TextEditingController(text: widget.cityControllerText);
    _stateController = TextEditingController(text: widget.stateControllerText);
    _countryController =
        TextEditingController(text: widget.countryControllerText);

    await getSavedPhone(_phoneController.text);

    if (!_isValidPhoneNumber) {
      getSavedPhone(user_phone.$);
    }

    setState(() {});
  }

  Future<void> onAddressUpdate(int id) async {
    final String address = _addressController.text.toString();
    final String postalCode = _postalCodeController.text.toString();

    if (address == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_address_ucf,
      );
      return;
    }

    if (_selected_country == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.select_a_country,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }
    if (_selected_state == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.select_a_state,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_selected_city == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.select_a_city,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }
    if (_phone.trim().isEmpty) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          color: Theme.of(context).colorScheme.error);
      return;
    } else if (!_isValidPhoneNumber) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.invalid_phone_number,
          color: Theme.of(context).colorScheme.error);
      return;
    }

    final addressUpdateResponse = await AddressRepository()
        .getAddressUpdateResponse(
            id: id,
            address: address,
            country_id: _selected_country!.id,
            state_id: _selected_state!.id,
            city_id: _selected_city!.id,
            postal_code: postalCode,
            phone: _phone);

    if (addressUpdateResponse.result == false) {
      ToastComponent.showDialog(
        addressUpdateResponse.message,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    ToastComponent.showDialog(
      addressUpdateResponse.message,
      color: Colors.green,
    );

    Navigator.of(context, rootNavigator: true).pop();
    widget.afterUpdatingAnAddress();
  }

  void onSelectCountryDuringUpdate(country) {
    if (country.id == _selected_country?.id) {
      setState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  void onSelectStateDuringUpdate(state) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  void onSelectCityDuringUpdate(city) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setState(() {
      _cityController.text = city.name;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitVal();
    fetch_country();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      contentPadding: const EdgeInsets.only(
          top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.address_ucf} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 55,
                  child: TextField(
                    controller: _addressController,
                    autofocus: false,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration:
                        InputDecorations.buildInputDecoration_with_border(
                            AppLocalizations.of(context)!.enter_address_ucf),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.country_ucf} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    controller: _countryController,
                    suggestionsCallback: (name) async {
                      final countryResponse =
                          await AddressRepository().getCountryList(name: name);
                      return countryResponse.countries;
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                AppLocalizations.of(context)!.enter_city_ucf),
                      );
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_countries_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic country) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          country.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (value) {
                      onSelectCountryDuringUpdate(value);
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.state_ucf} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    controller: _stateController,
                    suggestionsCallback: (name) async {
                      final stateResponse = await AddressRepository()
                          .getStateListByCountry(
                              country_id: _selected_country?.id, name: name);
                      return stateResponse.states;
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                AppLocalizations.of(context)!.enter_city_ucf),
                      );
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_states_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic state) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          state.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (value) {
                      onSelectStateDuringUpdate(value);
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.city_ucf} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    controller: _cityController,
                    suggestionsCallback: (name) async {
                      if (_selected_state == null) {
                        final CityResponse cityResponse =
                            await AddressRepository()
                                .getCityListByState(); // blank response
                        return cityResponse.cities;
                      }
                      final CityResponse cityResponse =
                          await AddressRepository().getCityListByState(
                              state_id: _selected_state?.id, name: name);
                      return cityResponse.cities;
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                AppLocalizations.of(context)!.enter_city_ucf),
                      );
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_cities_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, City city) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          city.name!,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (City city) {
                      onSelectCityDuringUpdate(city);
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${AppLocalizations.of(context)!.phone_ucf} *",
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Container(
                margin:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                  // boxShadow: [MyTheme.commonShadow()],
                ),
                height: 40,
                child: CustomInternationalPhoneNumberInput(
                  countries: countries_code,
                  height: 40,
                  backgroundColor: Colors.transparent,
                  hintText: LangText(context).local.phone_number_ucf,
                  errorMessage: LangText(context).local.invalid_phone_number,
                  initialValue: initialValue,
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      if (number.isoCode != null)
                        AppConfig.default_country = number.isoCode!;
                      _phone = number.phoneNumber ?? '';
                      print(_phone);
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
                  selectorTextStyle: const TextStyle(color: MyTheme.font_grey),
                  textStyle: const TextStyle(color: MyTheme.font_grey),
                  textFieldController: _phoneController,
                  formatInput: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  inputDecoration: InputDecorations.buildInputDecoration_phone(
                      hint_text: "01XXX XXX XXX"),
                  onSaved: (PhoneNumber number) {},
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text(AppLocalizations.of(context)!.postal_code,
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _postalCodeController,
                    autofocus: false,
                    decoration:
                        InputDecorations.buildInputDecoration_with_border(
                            AppLocalizations.of(context)!
                                .enter_postal_code_ucf),
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
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Btn.minWidthFixHeight(
                minWidth: 75,
                height: 40,
                color: const Color.fromRGBO(253, 253, 253, 1),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusHalfSmall),
                    side: BorderSide(color: MyTheme.light_grey, width: 1.0)),
                child: Text(
                  AppLocalizations.of(context)!.close_all_capital,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 13),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ),
            const SizedBox(width: 1),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 28.0),
              child: Btn.minWidthFixHeight(
                minWidth: 75,
                height: 40,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                ),
                child: Text(
                  AppLocalizations.of(context)!.update_all_capital,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  onAddressUpdate(widget.shippingAddress.id);
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
