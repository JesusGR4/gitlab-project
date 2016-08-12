from marshmallow import Schema, fields


class Product(Schema):
    id = fields.Str(required=True)
    title = fields.Str(required=True)
    width = fields.Int(required=True)
    flow_capacity = fields.Int(required=True)
    in_stock = fields.Int(required=True)
