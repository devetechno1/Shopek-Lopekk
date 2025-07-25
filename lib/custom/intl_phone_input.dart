import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/models/country_list.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/providers/country_provider.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:intl_phone_number_input/src/utils/phone_number.dart';
import 'package:intl_phone_number_input/src/utils/phone_number/phone_number_util.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/utils/widget_view.dart';
import 'package:intl_phone_number_input/src/widgets/countries_search_list_widget.dart';
import 'package:intl_phone_number_input/src/widgets/input_widget.dart';
import 'package:intl_phone_number_input/src/widgets/item.dart';

import '../my_theme.dart';

/// Enum for [CustomSelectorButton] types.
///
/// Available type includes:
///   * [PhoneInputSelectorType.DROPDOWN]
///   * [PhoneInputSelectorType.BOTTOM_SHEET]
///   * [PhoneInputSelectorType.DIALOG]

/// A [TextFormField] for [CustomInternationalPhoneNumberInput].
///
/// [initialValue] accepts a [PhoneNumber] this is used to set initial values
/// for phone the input field and the selector button
///
/// [selectorButtonOnErrorPadding] is a double which is used to align the selector
/// button with the input field when an error occurs
///
/// [locale] accepts a country locale which will be used to translation, if the
/// translation exist
///
/// [countries] accepts list of string on Country isoCode, if specified filters
/// available countries to match the [countries] specified.
class CustomInternationalPhoneNumberInput extends StatefulWidget {
  final SelectorConfig selectorConfig;

  final ValueChanged<PhoneNumber> onInputChanged;
  final ValueChanged<bool>? onInputValidated;

  final VoidCallback? onSubmit;
  final ValueChanged<String>? onFieldSubmitted;
  final String Function(String?)? validator;
  final ValueChanged<PhoneNumber>? onSaved;

  final TextEditingController? textFieldController;
  final TextInputType keyboardType;
  final TextInputAction? keyboardAction;

  final PhoneNumber? initialValue;
  final String hintText;
  final String errorMessage;

  final double selectorButtonOnErrorPadding;
  final double spaceBetweenSelectorAndTextField;
  final int maxLength;

  final bool isEnabled;
  final bool readOnly;
  final bool formatInput;
  final bool autoFocus;
  final bool autoFocusSearch;
  final AutovalidateMode autoValidateMode;
  final bool ignoreBlank;
  final bool countrySelectorScrollControlled;

  final String? locale;

  final TextStyle? textStyle;
  final TextStyle? selectorTextStyle;
  final InputBorder? inputBorder;
  final InputDecoration? inputDecoration;
  final InputDecoration? searchBoxDecoration;
  final Color? cursorColor;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final EdgeInsets scrollPadding;

  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  final List<String?>? countries;

  final Color? backgroundColor;

  final double? height;

  const CustomInternationalPhoneNumberInput({
    Key? key,
    this.selectorConfig = const SelectorConfig(),
    required this.onInputChanged,
    this.onInputValidated,
    this.onSubmit,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.textFieldController,
    this.keyboardAction,
    this.keyboardType = TextInputType.phone,
    this.initialValue,
    this.hintText = 'Phone number',
    this.errorMessage = 'Invalid phone number',
    this.selectorButtonOnErrorPadding = 24,
    this.spaceBetweenSelectorAndTextField = 12,
    this.maxLength = 15,
    this.isEnabled = true,
    this.readOnly = false,
    this.formatInput = true,
    this.autoFocus = false,
    this.autoFocusSearch = false,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.ignoreBlank = false,
    this.countrySelectorScrollControlled = true,
    this.locale,
    this.textStyle,
    this.selectorTextStyle,
    this.inputBorder,
    this.inputDecoration,
    this.searchBoxDecoration,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.focusNode,
    this.cursorColor,
    this.autofillHints,
    this.countries,
    this.backgroundColor,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<CustomInternationalPhoneNumberInput> {
  TextEditingController? controller;
  double selectorButtonBottomPadding = 0;

  Country? country;
  List<Country> countries = [];
  bool isNotValid = true;

  @override
  void initState() {
    super.initState();
    loadCountries();
    controller = widget.textFieldController ?? TextEditingController();
    initialiseWidget();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InputWidgetView(
      state: this,
    );
  }

  @override
  void didUpdateWidget(CustomInternationalPhoneNumberInput oldWidget) {
    if (oldWidget.initialValue?.hash != widget.initialValue?.hash) {
      loadCountries();
      initialiseWidget();
    } else {
      loadCountries(previouslySelectedCountry: country);
    }
    super.didUpdateWidget(oldWidget);
  }

  /// [initialiseWidget] sets initial values of the widget
  Future<void> initialiseWidget() async {
    if (widget.initialValue != null) {
      if (widget.initialValue!.phoneNumber != null &&
          widget.initialValue!.phoneNumber!.isNotEmpty &&
          (await PhoneNumberUtil.isValidNumber(
              phoneNumber: widget.initialValue!.phoneNumber!,
              isoCode: widget.initialValue!.isoCode!))!) {
        controller!.text =
            await PhoneNumber.getParsableNumber(widget.initialValue!);

        phoneNumberControllerListener();
      }
    }
  }

  /// loads countries from [Countries.countryList] and selected Country
  void loadCountries({Country? previouslySelectedCountry}) {
    if (mounted) {
      final List<Country> countries = CountryProvider.getCountriesData(
          countries: widget.countries!.cast<String>());

      final CountryComparator? countryComparator =
          widget.selectorConfig.countryComparator;
      if (countryComparator != null) {
        countries.sort(countryComparator);
      }

      final Country country = previouslySelectedCountry ??
          Utils.getInitialSelectedCountry(
            countries,
            widget.initialValue?.isoCode ?? '',
          );

      setState(() {
        this.countries = countries;
        this.country = country;
      });
    }
  }

  /// Listener that validates changes from the widget, returns a bool to
  /// the `ValueCallback` [widget.onInputValidated]
  void phoneNumberControllerListener() {
    if (mounted) {
      final String parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      getParsedPhoneNumber(parsedPhoneNumberString, country?.alpha2Code)
          .then((phoneNumber) {
        if (phoneNumber == null) {
          final String phoneNumber =
              '${country?.dialCode}$parsedPhoneNumberString';

          widget.onInputChanged(PhoneNumber(
              phoneNumber: phoneNumber,
              isoCode: country?.alpha2Code,
              dialCode: country?.dialCode));

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(false);
          }
          isNotValid = true;
        } else {
          widget.onInputChanged(PhoneNumber(
              phoneNumber: phoneNumber,
              isoCode: country?.alpha2Code,
              dialCode: country?.dialCode));

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(true);
          }
          isNotValid = false;
        }
      });
    }
  }

  /// Returns a formatted String of [phoneNumber] with [isoCode], returns `null`
  /// if [phoneNumber] is not valid or if an [Exception] is caught.
  Future<String?> getParsedPhoneNumber(
      String phoneNumber, String? isoCode) async {
    if (phoneNumber.isNotEmpty && isoCode != null) {
      try {
        final bool isValidPhoneNumber = (await PhoneNumberUtil.isValidNumber(
            phoneNumber: phoneNumber, isoCode: isoCode))!;

        if (isValidPhoneNumber) {
          return await PhoneNumberUtil.normalizePhoneNumber(
              phoneNumber: phoneNumber, isoCode: isoCode);
        }
      } on Exception {
        return null;
      }
    }
    return null;
  }

  /// Creates or Select [InputDecoration]
  InputDecoration getInputDecoration(InputDecoration? decoration) {
    final InputDecoration value = decoration ??
        InputDecoration(
          border: widget.inputBorder ?? const UnderlineInputBorder(),
          hintText: widget.hintText,
        );

    if (widget.selectorConfig.setSelectorButtonAsPrefixIcon) {
      return value.copyWith(
          prefixIcon: CustomSelectorButton(
        country: country,
        countries: countries,
        onCountryChanged: onCountryChanged,
        selectorConfig: widget.selectorConfig,
        selectorTextStyle: widget.selectorTextStyle,
        searchBoxDecoration: widget.searchBoxDecoration,
        locale: locale,
        isEnabled: !widget.readOnly && widget.isEnabled,
        autoFocusSearchField: widget.autoFocusSearch,
        isScrollControlled: widget.countrySelectorScrollControlled,
        backgroundColor: widget.backgroundColor,
        height: widget.height,
      ));
    }

    return value;
  }

  /// Validate the phone number when a change occurs
  void onChanged(String value) {
    phoneNumberControllerListener();
  }

  /// Validate and returns a validation error when [FormState] validate is called.
  ///
  /// Also updates [selectorButtonBottomPadding]
  String? validator(String? value) {
    final bool isValid =
        isNotValid && (value!.isNotEmpty || widget.ignoreBlank == false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isValid) {
        setState(() {
          selectorButtonBottomPadding = widget.selectorButtonOnErrorPadding;
        });
      } else {
        setState(() {
          selectorButtonBottomPadding = 0;
        });
      }
    });

    return isValid ? widget.errorMessage : null;
  }

  /// Changes Selector Button Country and Validate Change.
  void onCountryChanged(Country? country) {
    setState(() {
      this.country = country;
    });
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (mounted) {
      final String parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      getParsedPhoneNumber(parsedPhoneNumberString, country?.alpha2Code).then(
        (phoneNumber) => widget.onSaved?.call(
          PhoneNumber(
              phoneNumber: phoneNumber,
              isoCode: country?.alpha2Code,
              dialCode: country?.dialCode),
        ),
      );
    }
  }

  /// Saved the phone number when form is saved
  void onSaved(String? value) {
    _phoneNumberSaved();
  }

  /// Corrects duplicate locale
  String? get locale {
    if (widget.locale == null) return null;

    if (widget.locale!.toLowerCase() == 'nb' ||
        widget.locale!.toLowerCase() == 'nn') {
      return 'no';
    }
    return widget.locale;
  }
}

class _InputWidgetView
    extends WidgetView<CustomInternationalPhoneNumberInput, _InputWidgetState> {
  @override
  final _InputWidgetState state;

  const _InputWidgetView({Key? key, required this.state})
      : super(key: key, state: state);

  @override
  Widget build(BuildContext context) {
    final countryCode = state.country?.alpha2Code ?? '';
    final dialCode = state.country?.dialCode ?? '';

    return Container(
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomSelectorButton(
                country: state.country,
                countries: state.countries,
                onCountryChanged: state.onCountryChanged,
                selectorConfig: widget.selectorConfig,
                selectorTextStyle: widget.selectorTextStyle,
                searchBoxDecoration: widget.searchBoxDecoration,
                locale: state.locale,
                isEnabled: !widget.readOnly && widget.isEnabled,
                autoFocusSearchField: widget.autoFocusSearch,
                isScrollControlled: widget.countrySelectorScrollControlled,
                backgroundColor: widget.backgroundColor,
                height: widget.height, //+ 8,
              ),
              SizedBox(
                height: state.selectorButtonBottomPadding,
              ),
            ],
          ),
          Flexible(
            child: TextFormField(
              key: const Key(TestHelper.TextInputKeyValue),
              textDirection: TextDirection.ltr,
              controller: state.controller,
              focusNode: widget.focusNode,
              enabled: widget.isEnabled,
              readOnly: widget.readOnly,
              autofocus: widget.autoFocus,
              keyboardType: widget.keyboardType,
              textInputAction: widget.keyboardAction,
              style: widget.textStyle,
              decoration: state.getInputDecoration(widget.inputDecoration),
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              onEditingComplete: widget.onSubmit,
              onFieldSubmitted: widget.onFieldSubmitted,
              autovalidateMode: widget.autoValidateMode,
              autofillHints: widget.autofillHints,
              validator: widget.validator ?? state.validator,
              onSaved: state.onSaved,
              scrollPadding: widget.scrollPadding,
              inputFormatters: [
                LengthLimitingTextInputFormatter(widget.maxLength),
                widget.formatInput
                    ? AsYouTypeFormatter(
                        isoCode: countryCode,
                        dialCode: dialCode,
                        onInputFormatted: (TextEditingValue value) {
                          state.controller!.value = value;
                        },
                      )
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: state.onChanged,
            ),
          )
        ],
      ),
    );
  }
}

/// [CustomSelectorButton]
class CustomSelectorButton extends StatelessWidget {
  final List<Country> countries;
  final Country? country;
  final SelectorConfig selectorConfig;
  final TextStyle? selectorTextStyle;
  final InputDecoration? searchBoxDecoration;
  final bool autoFocusSearchField;
  final String? locale;
  final bool isEnabled;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? height;

  final ValueChanged<Country?> onCountryChanged;

  const CustomSelectorButton({
    Key? key,
    required this.countries,
    required this.country,
    required this.selectorConfig,
    required this.selectorTextStyle,
    required this.searchBoxDecoration,
    required this.autoFocusSearchField,
    required this.locale,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
    required this.backgroundColor,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN
        ? countries.isNotEmpty && countries.length > 1
            ? DropdownButtonHideUnderline(
                child: DropdownButton<Country>(
                  key: const Key(TestHelper.DropdownButtonKeyValue),
                  hint: Item(
                    country: country,
                    showFlag: selectorConfig.showFlags,
                    useEmoji: selectorConfig.useEmoji,
                    textStyle: selectorTextStyle,
                  ),
                  value: country,
                  items: mapCountryToDropdownItem(countries),
                  onChanged: isEnabled ? onCountryChanged : null,
                ),
              )
            : Item(
                country: country,
                showFlag: selectorConfig.showFlags,
                useEmoji: selectorConfig.useEmoji,
                textStyle: selectorTextStyle,
              )
        : Container(
            height: height ?? 36,
            decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                border: Border.all(color: MyTheme.textfield_grey, width: .5),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                    bottomLeft:
                        Radius.circular(AppDimensions.radiusHalfSmall))),
            child: TextButton(
              key: const Key(TestHelper.DropdownButtonKeyValue),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 20),
                backgroundColor: backgroundColor ?? Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                  bottomLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                )),
              ),
              onPressed: countries.isNotEmpty &&
                      countries.length > 1 &&
                      isEnabled
                  ? () async {
                      Country? selected;
                      if (selectorConfig.selectorType ==
                          PhoneInputSelectorType.BOTTOM_SHEET) {
                        selected = await showCountrySelectorBottomSheet(
                            context, countries);
                      } else {
                        selected =
                            await showCountrySelectorDialog(context, countries);
                      }

                      if (selected != null) {
                        onCountryChanged(selected);
                      }
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8.0),
                child: Item(
                  country: country,
                  showFlag: selectorConfig.showFlags,
                  trailingSpace: false,
                  useEmoji: selectorConfig.useEmoji,
                  textStyle: countries.length > 1 && isEnabled
                      ? null
                      : const TextStyle(color: MyTheme.textfield_grey),
                ),
              ),
            ),
          );
  }

  /// Converts the list [countries] to `DropdownMenuItem`
  List<DropdownMenuItem<Country>> mapCountryToDropdownItem(
      List<Country> countries) {
    return countries.map((country) {
      return DropdownMenuItem<Country>(
        value: country,
        child: Item(
          key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
          country: country,
          showFlag: selectorConfig.showFlags,
          useEmoji: selectorConfig.useEmoji,
          textStyle: selectorTextStyle,
          withCountryNames: false,
        ),
      );
    }).toList();
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.DIALOG] is selected
  Future<Country?> showCountrySelectorDialog(
      BuildContext context, List<Country> countries) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: CountrySearchListWidget(
            countries,
            locale,
            searchBoxDecoration: searchBoxDecoration,
            showFlags: selectorConfig.showFlags,
            useEmoji: selectorConfig.useEmoji,
            autoFocus: autoFocusSearchField,
          ),
        ),
      ),
    );
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.BOTTOM_SHEET] is selected
  Future<Country?> showCountrySelectorBottomSheet(
      BuildContext context, List<Country> countries) {
    return showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusNormal),
              topRight: Radius.circular(AppDimensions.radiusNormal))),
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 100),
          child: Stack(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
            ),
            DraggableScrollableSheet(
              builder: (BuildContext context, ScrollController controller) {
                return Container(
                  decoration: ShapeDecoration(
                    color: Theme.of(context).canvasColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusNormal),
                        topRight: Radius.circular(AppDimensions.radiusNormal),
                      ),
                    ),
                  ),
                  child: CountrySearchListWidget(
                    countries,
                    locale,
                    searchBoxDecoration: searchBoxDecoration,
                    scrollController: controller,
                    showFlags: selectorConfig.showFlags,
                    useEmoji: selectorConfig.useEmoji,
                    autoFocus: autoFocusSearchField,
                  ),
                );
              },
            ),
          ]),
        );
      },
    );
  }
}
