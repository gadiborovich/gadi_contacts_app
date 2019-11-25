import 'dart:io';

import 'package:contacts_app/data/contact.dart';
import 'package:contacts_app/ui/model/contacts_model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:image_picker/image_picker.dart';

class ContactForm extends StatefulWidget {
  final Contact editedContact;

  ContactForm({
    Key key,
    this.editedContact,
  }) : super(key: key);

  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  String _email;
  String _phoneNumber;
  File _contactImageFile;

  bool get isEditMode => widget.editedContact != null;
  bool get hasSelectedCustomImage => _contactImageFile != null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _contactImageFile = widget.editedContact?.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          SizedBox(height: 10),
          _buildContactPicture(),
          SizedBox(height: 10),
          TextFormField(
            onSaved: (value) => _name = value,
            validator: _validateName,
            initialValue: widget.editedContact?.name,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            onSaved: (value) => _email = value,
            validator: _validateEmail,
            initialValue: widget.editedContact?.email,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            onSaved: (value) => _phoneNumber = value,
            validator: _validatePhoneNumber,
            initialValue: widget.editedContact?.phoneNumber,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 10),
          RaisedButton(
            onPressed: _onSaveContactButtonPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('SAVE CONTACT'),
                Icon(
                  Icons.person,
                  size: 18,
                )
              ],
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
          )
        ],
      ),
    );
  }

  Widget _buildContactPicture() {
    final halfScreenDiameter = MediaQuery.of(context).size.width / 2;
    return Hero(
      tag: widget.editedContact?.hashCode ?? 0,
      child: GestureDetector(
        onTap: _onContactPictureTapped,
        child: CircleAvatar(
          radius: halfScreenDiameter / 2,
          child: _buildCircleAvatarContent(halfScreenDiameter),
        ),
      ),
    );
  }

  void _onContactPictureTapped() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _contactImageFile = imageFile;
    });
  }

  Widget _buildCircleAvatarContent(double halfScreenDiameter) {
    if (isEditMode || hasSelectedCustomImage) {
      return _buildEditModeCircleAvatarContent(halfScreenDiameter);
    } else {
      return Icon(
        Icons.add_a_photo,
        size: halfScreenDiameter / 2,
      );
    }
  }

  Widget _buildEditModeCircleAvatarContent(double halfScreenDiameter) {
    if (_contactImageFile == null) {
      return Icon(
        Icons.add_a_photo,
        size: halfScreenDiameter / 2,
      );
    } else {
      return ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            _contactImageFile,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  String _validateName(String value) {
    if (value.isEmpty) {
      return 'Enter a name';
    }
    return null;
  }

  String _validateEmail(String value) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (value.isEmpty) {
      return 'Enter an email';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String _validatePhoneNumber(String value) {
    final numberRegex = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');
    if (value.isEmpty) {
      return 'Enter a phone number';
    } else if (!numberRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _onSaveContactButtonPressed() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final newOrEditedContact = Contact(
        name: _name,
        email: _email,
        phoneNumber: _phoneNumber,
        isFavorite: widget.editedContact?.isFavorite ?? false,
        imageFile: _contactImageFile,
      );
      if (isEditMode) {
        newOrEditedContact.id = widget.editedContact.id;
        ScopedModel.of<ContactsModel>(context).updateContact(
          newOrEditedContact,
        );
      } else {
        ScopedModel.of<ContactsModel>(context).addContact(newOrEditedContact);
      }
      Navigator.of(context).pop();
    }
  }
}
