import json
import hashlib
import base64

def process_item(item):
    return {"input": item}

def process_data(data):
    processed_data = []

    for i, item in data:
        processed_data.append([i, process_item(item)])
    return processed_data


def get_header(returned_data):
    # Calculate MD5 checksum for the response
    md5digest = hashlib.md5(returned_data.encode('utf-8')).digest()
    response_headers = {
        'Content-MD5': base64.b64encode(md5digest)
    }
    return response_headers

def lambda_handler(event, context):
    print(event)
    try:
        input_data = json.loads(event.get('body')).get('data')

        # The return value should contain an array of arrays
        # (one inner array per input row for a scalar function).
        processed_data = process_data(input_data)
        returned_data = json.dumps({"data": processed_data})
        status_code = 200

    except Exception as error:
        print(error)
        status_code = 400
        returned_data = json.dumps({"error": "there was an error executing the function"})

    # Return the HTTP status code, the processed data,
    # and the headers (including the Content-MD5 header).
    return {
        'statusCode': status_code,
        'body': returned_data,
        'headers': get_header(returned_data)
    }
