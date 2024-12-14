abstract class PostRemouteDataSource {
  
}

class PostRemouteDataSourceImpl extends PostRemouteDataSource{
  
}

const jsonString = '''{
    "catalog": [
        {
            "id": "050747ed-c6aa-409c-835c-e7cd30bc4d98",
            "name": "Electronics",
            "description": "",
            "childCategories": [
               {
                    "id": "11b78509-0092-44b1-a0be-f3659933dcb6",
                    "name": "Smartphones",
                    "description": "Apple, Samsung, Xiaomi...,",
                    "attributes": [
                        {
                            "attributeKey": "Smartphone Brand",
                            "helperText": "Select Brand",
                            "subHelperText": "Select Models",
                            "widgetType": "oneSelectable",
                            "subWidgetsType": "oneSelectable",
                            "dataType": "string",
                            "values": [
                                {
                                    "attributeValueId": "b86657c8-83eb-4518-90e5-cb4b2944bbbe",
                                    "attributeKeyId": "bd4dbd51-8e3a-4725-93cd-61179b328245",
                                    "value": "Apple",
                                    "list": [
                                        {
                                            "modelId": "124095a2-9f59-4cfd-a84f-dd9bc5a40dfb",
                                            "name": "iPhone 3GS",
                                            "attributeId": "b86657c8-83eb-4518-90e5-cb4b2944bbbe"
                                        },
                                        {
                                            "modelId": "a7a2a6b9-b9ad-4587-9251-a5356b6b8f92",
                                            "name": "iPhone 4",
                                            "attributeId": "b86657c8-83eb-4518-90e5-cb4b2944bbbe"
                                        },
                                        {
                                            "modelId": "11d5628c-71a2-435a-b55d-3440e9d210aa",
                                            "name": "iPhone 4S",
                                            "attributeId": "b86657c8-83eb-4518-90e5-cb4b2944bbbe"
                                        }
                                    ]
                                },
                                {
                                    "attributeValueId": "165524e3-be60-41cb-b725-46bffb9eb3f5",
                                    "attributeKeyId": "bd4dbd51-8e3a-4725-93cd-61179b328245",
                                    "value": "Samsung",
                                    "list": [
                                        {
                                            "modelId": "fec4b931-a2a7-489c-9fd3-c885db9eb017",
                                            "name": "G9198",
                                            "attributeId": "165524e3-be60-41cb-b725-46bffb9eb3f5"
                                        },
                                        {
                                            "modelId": "d7ae1d97-99c1-44c7-9695-89df7ea3aea2",
                                            "name": "G9298",
                                            "attributeId": "165524e3-be60-41cb-b725-46bffb9eb3f5"
                                        },
                                        {
                                            "modelId": "8f1cfc6a-04ae-48fb-b6a6-0b359ef050b2",
                                            "name": "Galaxy A01 Core",
                                            "attributeId": "165524e3-be60-41cb-b725-46bffb9eb3f5"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "attributeKey": "Smartphone Storage",
                            "helperText": "Select Storage",
                            "widgetType": "oneSelectable",
                            "dataType": "string",
                            "subHelperText": "null",
                            "subWidgetsType": "null",
                            "values": [
                                {
                                    "attributeValueId": "6528763e-04f2-40a4-8270-a04d53099192",
                                    "attributeKeyId": "677d0449-8b79-43ca-b7ce-7d347ad4c685",
                                    "value": "8 GB",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                },
                                {
                                    "attributeValueId": "78ffdc22-e6c6-4b8b-b8fd-7518ab28aed9",
                                    "attributeKeyId": "677d0449-8b79-43ca-b7ce-7d347ad4c685",
                                    "value": "16 GB",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "attributeKey": "Smartphone RAM",
                            "helperText": "Select Ram",
                            "widgetType": "oneSelectable",
                            "subHelperText": "null",
                            "subWidgetsType": "null",
                            "dataType": "string",
                            "values": [
                                {
                                    "attributeValueId": "8782eff9-0194-439a-bb7e-adaed6370a6f",
                                    "attributeKeyId": "7e26c4a0-8b45-4739-be81-0f93c4322bac",
                                    "value": "4GB",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                },
                                {
                                    "attributeValueId": "8389bf21-0967-4b74-a81d-b21261fcf144",
                                    "attributeKeyId": "7e26c4a0-8b45-4739-be81-0f93c4322bac",
                                    "value": "8GB",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "attributeKey": "Smartwatch Color",
                            "helperText": "Select Color",
                            "widgetType": "colorSelectable",
                            "subHelperText": "null",
                            "subWidgetsType": "null",
                            "dataType": "string",
                            "values": [
                                {
                                    "attributeValueId": "babc0250-5e0d-4b3b-962e-10c8bbd54c28",
                                    "attributeKeyId": "67e28662-8b28-4dd2-bd63-26df677ed5f4",
                                    "value": "Black",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                },
                                {
                                    "attributeValueId": "d056fa0a-0609-4955-bf1a-2c40f86b46f3",
                                    "attributeKeyId": "67e28662-8b28-4dd2-bd63-26df677ed5f4",
                                    "value": "Silver",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "attributeKey": "Phone Accessories",
                            "helperText": "Select Accessories",
                            "subHelperText": "null",
                            "widgetType": "multiSelectable",
                            "subWidgetsType": "null",
                            "dataType": "string",
                            "values": [
                                {
                                    "attributeValueId": "098f850c-8d1a-47ef-825a-a684b5b3141c",
                                    "attributeKeyId": "34c2eb5b-7130-450a-9f2c-fee714199a4f",
                                    "value": "Charging Dock",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                },
                                {
                                    "attributeValueId": "7cf1e6b3-a34a-4153-af9b-a776fd6504a5",
                                    "attributeKeyId": "34c2eb5b-7130-450a-9f2c-fee714199a4f",
                                    "value": "Charging Cable",
                                    "list": [
                                        {
                                            "modelId": null,
                                            "name": null,
                                            "attributeId": null
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                {
                    "id": "7f2f0f5b-abd5-4a19-95ad-f558dfa45f7d",
                    "name": "Laptops",
                    "description": "Ultrabook, Gaming, Business...",
                    "attributes": [
                        {
                            "attributeKey": "Laptop Brand",
                            "helperText": "Select Brand",
                            "subHelperText": "Select Model",
                            "widgetType": "oneSelectable",
                            "subWidgetsType": "oneSelectable",
                            "dataType": "string",
                            "values": [
                                {
                                    "attributeValueId": "2b261b7c-5750-4d0a-ab29-e7c2e3bca3b1",
                                    "attributeKeyId": "c0a2e2ce-7fb3-4306-944d-b6495ec73227",
                                    "value": "Dell",
                                    "list": [
                                        {
                                            "modelId": "bd268a24-57ab-4ff1-a78c-61b4231d6859",
                                            "name": "Inspiron,Inspiron 15 3000",
                                            "attributeId": "2b261b7c-5750-4d0a-ab29-e7c2e3bca3b1"
                                        },
                                        {
                                            "modelId": "77426669-9e72-43b0-8ce5-aa5a0f662263",
                                            "name": "Inspiron,Inspiron 14 5000",
                                            "attributeId": "2b261b7c-5750-4d0a-ab29-e7c2e3bca3b1"
                                        }
                                    ]
                                },
                                {
                                    "attributeValueId": "92b5580b-5b81-4a64-a430-5d5daf4f3edd",
                                    "attributeKeyId": "c0a2e2ce-7fb3-4306-944d-b6495ec73227",
                                    "value": "HP",
                                    "list": [
                                        {
                                            "modelId": "74cf7d48-a498-4ae3-8c55-22d9bc75700e",
                                            "name": "Pavilion,Pavilion 15",
                                            "attributeId": "92b5580b-5b81-4a64-a430-5d5daf4f3edd"
                                        },
                                        {
                                            "modelId": "fc6f2c21-f2a3-472e-8f37-db1326a0203f",
                                            "name": "Pavilion,Pavilion x360",
                                            "attributeId": "92b5580b-5b81-4a64-a430-5d5daf4f3edd"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "attributeKey": "Laptop Storage Types",
                            "helperText": "Select Storage Types",
                            "subHelperText": "Select",
                            "widgetType": "multiSelectable",
                            "subWidgetsType": "oneSelectable",
                            "dataType": "string",
                            "values": [
                                {
                                    "attributeValueId": "f4964cd9-c2d2-4db6-8870-4718911d977b",
                                    "attributeKeyId": "c601d5f6-7a14-4f07-8960-3d2b7deed5d2",
                                    "value": "HDD",
                                    "list": [
                                         {
                                            "modelId": "bd268a24-57ab-4ff1-a78c-61b4231d6859",
                                            "name": "2121GB",
                                            "attributeId": "f4964cd9-c2d2-4db6-8870-4718911d977b"
                                        },
                                        {
                                            "modelId": "77426669-9e72-43b0-8ce5-aa5a0f662263",
                                            "name": "566Gb",
                                            "attributeId": "f4964cd9-c2d2-4db6-8870-4718911d977b"
                                        }
                                    ]
                                },
                                {
                                    "attributeValueId": "1638a6ee-fcfd-4eda-b2a8-8db8c198dedc",
                                    "attributeKeyId": "c601d5f6-7a14-4f07-8960-3d2b7deed5d2",
                                    "value": "SSD",
                                    "list": [
                                          {
                                            "modelId": "1638a6ee-fcfd-4edaewew-b2a8-8db8c198dedc",
                                            "name": "127",
                                            "attributeId": "2b261b7c-5750-4d0a-ab29-e7c2e3bca3b1"
                                        },
                                        {
                                            "modelId": "1638a6ee-refcfd-4eda-b2a8-8db8cew198dedc",
                                            "name": "256Gb",
                                            "attributeId": "2b261b7c-5750-4d0a-ab29-e7c2e3bca3b1"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}''';