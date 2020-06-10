from __future__ import print_function

import hashlib
import requests
import time

def login_user(email, password):
    data = {
        'email': email,
        'password': password,
    }
    response = requests.post('http://localhost:5000/user/login', data=data)
    return response.json()


def create_user(email, password, name, vehicle_type, vehicle_color, license_plate, token):
    data = {
        'email': email,
        'password': password,
        'name': name,
        'vehicleType': vehicle_type,
        'vehicleColor': vehicle_color,
        'licensePlate': license_plate,
        'token': token,
    }
    response = requests.post('http://localhost:5000/user/create', data=data)
    return response.json()


def update_user(email, password, name, vehicle_type, vehicle_color, license_plate, token):
    data = {
        'email': email,
        'password': password,
        'name': name,
        'vehicleType': vehicle_type,
        'vehicleColor': vehicle_color,
        'licensePlate': license_plate,
        'token': token,
    }
    response = requests.post('http://localhost:5000/user/update', data=data)
    return response.json()


def create_order(customer_email, order_items, order_total):
    data = {
        'customerEmail': customer_email,
        'orderItems': order_items,
        'orderTotal': order_total,
    }
    response = requests.post('http://localhost:5000/order/create', data=data)
    return response.json()


def list_orders(customer_email):
    data = {
        'customerEmail': customer_email,
    }
    response = requests.post('http://localhost:5000/orders', data=data)
    return response.json()


def delete_order(order_id):
    data = {
        'orderId': order_id,
    }
    response = requests.post('http://localhost:5000/order/delete', data=data)
    return response.json()


if __name__ == '__main__':

    new_user = {
        'email': 'peppa@pig.com',
        'password': 'oink',
        'name': 'Peppa Pig',
        'vehicle_type': 'Sedan',
        'vehicle_color': 'Pink',
        'license_plate': 'SNORT',
        'token': None,
    }

    create_user_response = create_user(**new_user)
    create_user_pass = create_user_response['result'] == 'success'
    print('Create User Passed: %s' % create_user_pass)

    duplicate_user_response = create_user(**new_user)
    duplicate_user_pass = duplicate_user_response['result'] == 'error'
    print('Duplicate User Create Rejected: %s' % duplicate_user_pass)

    good_login_user_response = login_user('peppa@pig.com', 'oink')
    good_login_pass = good_login_user_response['result'] == 'success'
    print('Log in User Pass: %s' % good_login_pass)

    bad_login_user_response = login_user('peppa@pig.com', 'BADPASSWORD')
    bad_login_pass = bad_login_user_response['result'] == 'error'
    print('Bad Login Pass: %s' % bad_login_pass)

    new_user['token'] = hashlib.md5(str(time.time())).hexdigest()
    update_user_response = update_user(**new_user)
    update_user_pass = update_user_response['result'] == 'success' and update_user_response['user']['token'] == new_user['token']
    print('Update User Pass: %s' % update_user_pass)

    new_order = {
        'customer_email': 'peppa@pig.com',
        'order_items': "Burger1, Burger 2",
        'order_total': 8.99
    }

    create_order_response = create_order(**new_order)
    create_order_pass = create_order_response['result'] == 'success'
    created_order_id = create_order_response.get('order_id')
    print('Create Order Passed: %s' % create_order_pass)

    list_order_response = list_orders('peppa@pig.com')
    list_order_pass = list_order_response['result'] == 'success' and list_order_response['orders'] != []
    print('List Orders Passed: %s' % list_order_pass)

    delete_order_response = delete_order(created_order_id)
    delete_order_pass = delete_order_response['result'] == 'success'
    print('Delete Order Passed: %s' % delete_order_pass)

    bad_delete_order_response = delete_order("BADID")
    bad_delete_order_pass = bad_delete_order_response['result'] == 'error'
    print('Bad Delete Order Passed: %s' % bad_delete_order_pass)
