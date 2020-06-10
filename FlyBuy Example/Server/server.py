import flask
import json
import time


def read_users():
    with open('users.json', 'r') as f:
        users = json.loads(f.read())

    return users


def write_users(users):
    with open('users.json', 'w') as f:
        f.write(json.dumps(users, indent=2))


def read_orders():
    with open('orders.json', 'r') as f:
        orders = json.loads(f.read())

    return orders


def write_orders(orders):
    with open('orders.json', 'w') as f:
        f.write(json.dumps(orders, indent=2))

    return orders


if __name__ == '__main__':

    app = flask.Flask(__name__)

    @app.route('/user/login', methods=['POST'])
    def user_login():
        email = flask.request.form.get('email')
        password = flask.request.form.get('password')
        users = read_users()

        for user in users:
            if user['email'] == email and user['password'] == password:
                return json.dumps({'result': 'success', 'user': user})

        return json.dumps({'result': 'error'}), 401


    @app.route('/user/create', methods=['POST'])
    def user_create():
        new_user = {
            'name': flask.request.form.get('name'),
            'email': flask.request.form.get('email'),
            'password': flask.request.form.get('password'),
            'vehicle_type': flask.request.form.get('vehicleType'),
            'vehicle_color': flask.request.form.get('vehicleColor'),
            'license_plate': flask.request.form.get('licensePlate'),
            'token': flask.request.form.get('token'),
        }

        users = read_users()
        existing_emails = [u['email'] for u in users]

        if flask.request.form.get('email') not in existing_emails:
            users.append(new_user)
            write_users(users)
            return json.dumps({'result': 'success', 'user': new_user})

        return json.dumps({'result': 'error', 'message': 'user already exists'}), 403


    @app.route('/user/update', methods=['POST'])
    def user_update():
        users = read_users()
        for user in users:
            email_matches = user.get('email') == flask.request.form.get('email')
            password_matches = user.get('password') == flask.request.form.get('password')

            if email_matches and password_matches:
                user['password'] = flask.request.form.get('password')
                user['name'] = flask.request.form.get('name')
                user['vehicle_type'] = flask.request.form.get('vehicleType')
                user['vehicle_color'] = flask.request.form.get('vehicleColor')
                user['license_plate'] = flask.request.form.get('licensePlate')
                user['token'] = flask.request.form.get('token')

                write_users(users)
                return json.dumps({'result': 'success', 'user': user})

        return json.dumps({'result': 'error', 'message': 'unauthorized'}), 401


    @app.route('/orders', methods=['POST'])
    def orders():
        orders = read_orders()
        customer_email = flask.request.form.get('customerEmail')
        customer_orders = [o for o in orders if o.get('customer_email') == customer_email]
        sorted_customer_orders = sorted(customer_orders, key=lambda k: k.get('created_at'), reverse=True)
        return json.dumps({'result': 'success', 'orders': sorted_customer_orders})


    @app.route('/order/create', methods=['POST'])
    def order_create():
        new_order = {
            'order_id': str(int(time.time())),
            'customer_email': flask.request.form.get('customerEmail'),
            'items': flask.request.form.get('orderItems'),
            'total': float(flask.request.form.get('orderTotal')),
            'created_at': int(time.time()),
        }

        orders = read_orders()
        orders.append(new_order)
        write_orders(orders)
        return json.dumps({'result': 'success', 'order_id': new_order['order_id']})


    @app.route('/order/delete', methods=['POST'])
    def order_delete():
        orders = read_orders()

        try:
            order_ids = [o.get('order_id') for o in orders]
            target_order_id = flask.request.form.get('orderId')
            matching_order_index = order_ids.index(target_order_id)
            orders.pop(matching_order_index)
            write_orders(orders)
            return json.dumps({'result': 'success'})
        except ValueError:
            return json.dumps({'result': 'error', 'message': 'order not found'})


    app.run(debug=True)
