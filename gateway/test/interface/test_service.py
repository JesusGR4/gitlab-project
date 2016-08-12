import json

from mock import call

from gateway.exceptions import OrderNotFound, ProductNotFound


class TestGetProduct(object):
    def test_can_get_product(self, gateway_service, web_session):
        gateway_service.products_rpc.get.return_value = {
            "in_stock": 10,
            "flow_capacity": 5,
            "id": "shit_vacuum_2000",
            "width": 101,
            "title": "Shit Vacuum 2000"
        }
        response = web_session.get('/products/shit_vacuum_2000')
        assert response.status_code == 200
        assert gateway_service.products_rpc.get.call_args_list == [
            call("shit_vacuum_2000")
        ]
        assert response.json() == {
            "in_stock": 10,
            "flow_capacity": 5,
            "id": "shit_vacuum_2000",
            "width": 101,
            "title": "Shit Vacuum 2000"
        }

    def test_product_not_found(self, gateway_service, web_session):
        gateway_service.products_rpc.get.side_effect = (
            ProductNotFound('missing'))

        # call the gateway service to get order #1
        response = web_session.get('/products/foo')
        assert response.status_code == 404
        payload = response.json()
        assert payload['error'] == 'PRODUCT_NOT_FOUND'
        assert payload['message'] == 'missing'


class TestCreateProduct(object):
    def test_can_create_product(self, gateway_service, web_session):
        response = web_session.post(
            '/products',
            json.dumps({
                "in_stock": 10,
                "flow_capacity": 5,
                "id": "shit_vacuum_2000",
                "width": 101,
                "title": "Shit Vacuum 2000"
            })
        )
        assert response.status_code == 200
        assert response.json() == {'id': 'shit_vacuum_2000'}
        assert gateway_service.products_rpc.create.call_args_list == [call({
                "in_stock": 10,
                "flow_capacity": 5,
                "id": "shit_vacuum_2000",
                "width": 101,
                "title": "Shit Vacuum 2000"
            })]

    def test_create_product_fails_with_invalid_json(
        self, gateway_service, web_session
    ):
        response = web_session.post(
            '/products', 'NOT-JSON'
        )
        assert response.status_code == 400
        assert response.json()['error'] == 'BAD_REQUEST'

    def test_create_product_fails_with_invalid_data(
        self, gateway_service, web_session
    ):
        response = web_session.post(
            '/products',
            json.dumps({"id": 1})
        )
        assert response.status_code == 400
        assert response.json()['error'] == 'VALIDATION_ERROR'


class TestGetOrder(object):

    def test_can_get_order(self, gateway_service, web_session):
        # setup mock orders-service response:
        gateway_service.orders_rpc.get_order.return_value = {
            'id': 1,
            'order_details': [
                {
                    'id': 1,
                    'quantity': 2,
                    'product_id': 'shit_vacuum_2000',
                    'price': '200.00'
                },
                {
                    'id': 2,
                    'quantity': 1,
                    'product_id': 'the_enigma',
                    'price': '400.00'
                }
            ]
        }

        # setup mock products-service response:
        gateway_service.products_rpc.list.return_value = [
            {
                'id': 'shit_vacuum_2000',
                'title': 'Shit Vacuum 2000',
                'flow_capacity': 3,
                'in_stock': 899,
                'width': 100
            },
            {
                'id': 'the_enigma',
                'title': 'The Enigma',
                'flow_capacity': 200,
                'in_stock': 1,
                'width': 4
            },
        ]

        # call the gateway service to get order #1
        response = web_session.get('/orders/1')
        assert response.status_code == 200

        expected_response = {
            'id': 1,
            'order_details': [
                {
                    'id': 1,
                    'quantity': 2,
                    'product_id': 'shit_vacuum_2000',
                    'image':
                        'http://example.com/airship/images/shit_vacuum_2000.jpg',
                    'product': {
                        'id': 'shit_vacuum_2000',
                        'title': 'Shit Vacuum 2000',
                        'flow_capacity': 3,
                        'in_stock': 899,
                        'width': 100
                    },
                    'price': '200.00'
                },
                {
                    'id': 2,
                    'quantity': 1,
                    'product_id': 'the_enigma',
                    'image':
                        'http://example.com/airship/images/the_enigma.jpg',
                    'product': {
                        'id': 'the_enigma',
                        'title': 'The Enigma',
                        'flow_capacity': 200,
                        'in_stock': 1,
                        'width': 4
                    },
                    'price': '400.00'
                }
            ]
        }
        assert expected_response == response.json()

        # check dependencies called as expected
        assert [call(1)] == gateway_service.orders_rpc.get_order.call_args_list
        assert [call()] == gateway_service.products_rpc.list.call_args_list

    def test_order_not_found(self, gateway_service, web_session):
        gateway_service.orders_rpc.get_order.side_effect = (
            OrderNotFound('missing'))

        # call the gateway service to get order #1
        response = web_session.get('/orders/1')
        assert response.status_code == 404
        payload = response.json()
        assert payload['error'] == 'ORDER_NOT_FOUND'
        assert payload['message'] == 'missing'


class TestCreateOrder(object):

    def test_can_create_order(self, gateway_service, web_session):
        # setup mock products-service response:
        gateway_service.products_rpc.list.return_value = [
            {
                'id': 'shit_vacuum_2000',
                'title': 'Shit Vacuum 2000',
                'flow_capacity': 3,
                'in_stock': 899,
                'width': 100
            },
            {
                'id': 'the_enigma',
                'title': 'The Enigma',
                'flow_capacity': 200,
                'in_stock': 1,
                'width': 4
            },
        ]

        # setup mock create response
        gateway_service.orders_rpc.create_order.return_value = {
            'id': 11,
            'order_details': []
        }

        # call the gateway service to create the order
        response = web_session.post(
            '/orders',
            json.dumps({
                'order_details': [
                    {
                        'product_id': 'shit_vacuum_2000',
                        'price': '41.00',
                        'quantity': 3
                    }
                ]
            })
        )
        assert response.status_code == 200
        assert response.json() == {'id': 11}
        assert gateway_service.products_rpc.list.call_args_list == [call()]
        assert gateway_service.orders_rpc.create_order.call_args_list == [
            call([
                {'product_id': 'shit_vacuum_2000', 'quantity': 3, 'price': '41.00'}
            ])
        ]

    def test_create_order_fails_with_invalid_json(
        self, gateway_service, web_session
    ):
        # call the gateway service to create the order
        response = web_session.post(
            '/orders', 'NOT-JSON'
        )
        assert response.status_code == 400
        assert response.json()['error'] == 'BAD_REQUEST'

    def test_create_order_fails_with_invalid_data(
        self, gateway_service, web_session
    ):
        # call the gateway service to create the order
        response = web_session.post(
            '/orders',
            json.dumps({
                'order_details': [
                    {
                        'product_id': 'shit_vacuum_2000',
                        'price': '41.00',
                    }
                ]
            })
        )
        assert response.status_code == 400
        assert response.json()['error'] == 'VALIDATION_ERROR'

    def test_create_order_fails_with_unknown_product(
        self, gateway_service, web_session
    ):
        # setup mock products-service response:
        gateway_service.products_rpc.list.return_value = [
            {
                'id': 'shit_vacuum_2000',
                'title': 'Shit Vacuum 2000',
                'flow_capacity': 3,
                'in_stock': 899,
                'width': 100
            },
            {
                'id': 'the_enigma',
                'title': 'The Enigma',
                'flow_capacity': 200,
                'in_stock': 1,
                'width': 4
            },
        ]

        # call the gateway service to create the order
        response = web_session.post(
            '/orders',
            json.dumps({
                'order_details': [
                    {
                        'product_id': 'unknown',
                        'price': '41',
                        'quantity': 1
                    }
                ]
            })
        )
        assert response.status_code == 404
        assert response.json()['error'] == 'PRODUCT_NOT_FOUND'
        assert response.json()['message'] == 'Product Id unknown'
